---
ID: 2162
post_title: >
  Developing graceful microservices by
  CorpJS
author: Peter Hauszknecht
post_date: 2017-03-22 14:28:42
post_excerpt: ""
layout: post
permalink: >
  http://molin.io/the-graceful-microservice-lifecycle/
published: true
tags: [ ]
categories:
  - Microservices
---
### Introduction

A process that runs in a production environment has to start and stop gracefully, regardless of being monolothic service or a microservice. The reason of having such graceful operation is the following: usually, there are dependencies beetween the runtime resources of the process so to have an error-free start, these need to start in a particular order, waiting for each other. The same is true for stopping.   

Graceful start is trivial in a way that we cannot force our app to start if things do not happen this way. Graceful stop however is missed by many, saying for example that "it will stop eventually". If you have a monolithic app, this is not that much of a problem, while in a microservices architecture suddenly terminating a process can have nasty side-effects.

Having graceful operation is not a new thing. Its main concept is to separate the runtime resources as the components of the app (config, logger, server, db client, message queue client, etc.), implementing well-defined asynchronous `start` and `stop` methods. We start the components in their dependency order, so the whole app has an async `start` and `stop` method.

In this post, we'll demonstrate graceful implementation by using the [corpjs-system](https://www.npmjs.com/package/corpjs-system) module, also introducing a few weaker, additional requirements and practicies which are connected to this topic.

### System basics

[corpjs-system](https://www.npmjs.com/package/corpjs-system) is a graceful component-management module written in TypeScript. Its components must have the following structure:

```javascript
{
  async start(dependencies?, restart?, stop?) { ... },
  async stop() { ... }
}
```

`start` and `stop` methods must return with `Promise`. Definition of the former is mandatory, while the latter is not. The resolved return value of the `start` method (which is a `Promise`) will be resource delegated by the component.

It's recommended to define the components as classes or factory function, to enable multiinstance usage, such asusing them as closure, but we can also give other parameters to component instance through the factory arguments.

Finally, we unite the components into a `System`:

```javascript
const system = new System()
  .add(&#039;config&#039;, Config())
  .add(&#039;logger&#039;, Logger()).dependsOn(&#039;config&#039;)
  .add(&#039;mongodb&#039;, MongoDb()).dependsOn(&#039;config&#039;, &#039;logger&#039;)

system.start().then(resources =&gt; console.log(resources))

...

system.stop().then(() =&gt; console.log(&quot;Good bye!&quot;))
```

When we start the `system`, that will start the components in the dependency order, giving them their dependencies:

```javascript
function MongoDb(useUri) {
  let db
  return {
    async start({config, logger}) {
      const connectionConfig = useUri ? config.mongodb.connUri : config.mongodb.connConfig
      db = await MongoClient.connect(connectionConfig)
      logger.log(&quot;Connection details:&quot;, connectionConfig)
      return db
    },
    async stop() {
      if (db) await db.close()
    }
  }
}
```

### Dependencies

When we define the dependencies, we have the chance to overwrite their name and/or content for the dependent component:

```javascript
const system = new System()
  .add(&#039;config&#039;, Config())
  .add(&#039;logger&#039;, Logger()).dependsOn(&#039;config&#039;)
  .add(&#039;mongodb&#039;, MongoDb()).dependsOn({component: &#039;config&#039;, source: &#039;mongodb&#039;, as: &#039;mongodbConfig&#039;}, &#039;logger&#039;)
```

The `MongoDB` component only gets the `MongoDB` part from the `config`, under the name `mongodbConfig`.

### Lifecycle methods

The `start` function of the component will receive two additional lifecycle methods as arguments, besides the resources of its dependencies: `systemRestart`, `systemStop`. Components will have the chance to invoke the full restart and stop of the whole `system` with these functions.

```javascript
function Config(path) {
  let watcher
  return {
    async start(_, systemRestart, systemStop) {
      watcher = watch(path, () =&gt; systemRestart())
      watcher.on(&#039;error&#039;, systemStop)
      return readJson(path)
    },
    async stop() {
      if (watcher) watcher.close()
    }
  }
}
```

In the example above, the component will enforce the system to restart upon the change of the config file. After such a `systemRestart`, the whole `system` is stopped and restarted gracefully, without exiting the process.

By using the `systemStop` function received as an argument, we can force the system to stop and exit. If we call the `systemStop` with an error, then we can propagate our exception to the system, which will make the exit of the process with error code 1.

We can disable the exiting in case of an exception with the:

```javascript
new System({ exitOnError: false })
```

setting, which can be beneficial when we're running tests.

### Error handling

When we constructed the underlying principles of [corpjs-system](https://www.npmjs.com/package/corpjs-system), we deemed the usage in production environments more imortant, so error handling was created by following this formula.

1) When the starting flow of the `system` encounters and error (meaning, any of the components throws a `start` exception), the system stops all started components gracefully and exits the process.
2) When any of the components calls `systemStop` with an exception, we do the same.
3) When a `stop` method of a component in the stopping flow throws an exception, we skip the component and continue the graceful stop, finally exiting the process.
4) When stopping reaches its timeout, it exits the process. We can set this via the `terminationTimeout` setting on the `System` instance.  
5) In case of `uncaughtException` or `unhandledRejection`, the system is stopped gracefully and the process exits.

The stop the exit of the process in case of an error, we must set `exitOnError: false`.

Exit of a process is preferred by [corpjs-system](https://www.npmjs.com/package/corpjs-system) because its fate is handled by the infrastructure, and not the process itself. This is the preferred design in a microservices architecture, since stopping of a given process can have impact on other parts of the architecture as well. This way, the infrastructure can decide whether the service must be restarted without further consideration, or perhaps it should do some investigation regarding the cause of the error - for example if a database, which is a strong dependency, is not available.

### Ignorable components

A system has important (mandatory) and less important (ignorable) components. Ignorable components will have their errors ingored in the first two cases above. We can define an ignorable component the following way:

```javascript
const system = new System()
  .add(&#039;config&#039;, Config())
  .add(&#039;logger&#039;, Logger()).ignorable().dependsOn(&#039;config&#039;)
  .add(&#039;mongodb&#039;, MongoDb()).dependsOn(&#039;config&#039;, &#039;logger&#039;)
```

In this example, if there's an error when the `logger` component is started, we skip it. If it asks for stop because of an exception, we ignore it.

### Signal handling

`system` watches `SIGINT` and `SIGTERM`. It is stopped in a graceful way in the cases of such interruption or termination. Most of the process managers terminate processes by using such signals, so their handling is mandatory.

### Grouping

So you might ask whether it makes sense to organize these systems in a deeper hierarchy or not. For example, when creating a closed test system, organizing `system` into smaller parts can be useful, but we can also have a code organization where a single module only publishes a half component: 

```javascript
// adminApiSystem.js
const adminApi = new System()
  .add(&#039;adminRouter&#039;, AdminApiRouter())
  .add(&#039;auth&#039;, AdminAuth()).dependsOn(&#039;adminRouter&#039;)
  .add(&#039;users&#039;, Users()).dependsOn(&#039;adminRouter&#039;)
  .add(&#039;orders&#039;, Orders()).dependsOn(&#039;adminRouter&#039;)
  .group()

// publicApiSystem.js
const publicApi = new System()
  .add(&#039;publicRouter&#039;, PublicApiRouter())
  .add(&#039;auth&#039;, Auth()).dependsOn(&#039;publicRouter&#039;)
  .add(&#039;cart&#039;, Cart()).dependsOn(&#039;publicRouter&#039;)
  .add(&#039;products&#039;, Products()).dependsOn(&#039;publicRouter&#039;)
  .group()

// system.js
const system = new System()
  .add(&#039;root&#039;, ExpressApp())
  .add(&#039;adminRouter&#039;, adminApi).dependsOn(&#039;root&#039;)
  .add(&#039;publicRouter&#039;, publicApi).dependsOn(&#039;root&#039;)
  .add(&#039;server&#039;, Server()).dependsOn(&#039;root&#039;, &#039;adminRouter&#039;, &#039;publicRouter&#039;)
```

### Emitted events

`system` is also an EventEmitter, emitting a couple of useful events. As we prefer to know about every event, the `logAllEvents()` method watches and logs every event to the standard output:

```javascript
const system = new System()
  ...
  .logAllEvents()
```

### Upcoming features

[corpjs-system](https://www.npmjs.com/package/corpjs-system) is a prototype, perfecting and revamping the feature sets of [electrician](https://www.npmjs.com/package/electrician) and [systemic](https://www.npmjs.com/package/systemic).

Enhancements currently missing but already in the backlog are:

- Removal and override of components: these can also be useful when you are developing test systems, helping us to mock existing systems.
- Option to set start timeout with further configuration options.
- Usage of the `logAllEvents()` function with other loggers, not only stdout.

### The `corpjs` component set

We're publishing a basic component set for [corpjs-system](https://www.npmjs.com/package/corpjs-system), which:
- has all `System` compatible,
- are created using the principles described in this post.

This is an incomplete list of components, it will grow in the future:

- [corpjs-config](https://www.npmjs.com/package/corpjs-config): A config reader and watcher module, based on [confabulous](https://www.npmjs.com/package/confabulous) ,which fallbacks the structures of the configs in the given order. It restarts the system when the config is changed.
- [corpjs-endpoints](https://www.npmjs.com/package/corpjs-endpoints): Handles a special case of config: endpoints. When creating a microservices architecture, it is paramount for the differents parts of the architecture to know the network endpoints of their dependencies. If the infrastrcture can serve this information into a file (for which molinio is great!), then this module is a perfect choice to watch this file and testart the system when it changes. Extending the endpoints to other protocols is in the backlog.
- [corpjs-logger](https://www.npmjs.com/package/corpjs-logger): This module wraps [winston](https://www.npmjs.com/package/winston) as a `System` compatible component. The component delegates a `Logger` instance.
- [corpjs-express](https://www.npmjs.com/package/corpjs-express): express `App`- and `Server`-components.
- [corpjs-mongodb](https://www.npmjs.com/package/corpjs-mongodb): delegating MongoDB instance.
- [corpjs-amqp](https://www.npmjs.com/package/corpjs-mongodb): RabbitMQ connection- and channel-components.

## The CorpJS microservice concepts

The main purpose of the CorpJS product family is to publish standards which cover the Corporate Microservices requirements, by using the design patterns described above. To achieve this, we started to create yeoman generators which will ease the pain for developers to create sekeletons, plus these boilerplates will serve as guidelines to create microservices.

### The Yeoman generators

- [Rest Service](https://www.npmjs.com/package/generator-corpjs-ts-service-rest): Simple express rest service. Developers only need to implement the router components.- [Message Controlled Worker Service](https://www.npmjs.com/package/generator-corpjs-ts-service-amqp-worker): Workers service which can be read from RabbitMQ. Developers only need to implement consumers. The boilerplate is prepared to handle dynamic configs and endpoints.
- [React Application Host Service](https://www.npmjs.com/package/generator-corpjs-ts-app-react): A simple React app packed with Webpack, using `redux` and `redux-thunk`. The boilerplate constructs the whole folder structure, data- and workflow configuration. Developers only need to implement reducers, actionCreators and components. The service hosting the app is created based on the rest-service mentioned before.
- [MongoDB](https://www.npmjs.com/package/generator-corpjs-mongodb): Docker-compose file using `mongodb` image.
- [RabbitMQ](https://www.npmjs.com/package/generator-corpjs-rabbitmq): Docker-compose file using `rabbitmq:3-management`.

#### Upcoming generators

- OData Rest Services: OData based rest services based on [odata-v4-server](https://www.npmjs.com/package/odata-v4-server) and `odata-v4-` database connectors.

Every generator uses the [generator-corpjs-ts](https://www.npmjs.com/package/generator-corpjs-ts) base generator, which creates a simple TypeScript-based boilerplate.

We will soon make some vanilla JS-based generators available as well.
