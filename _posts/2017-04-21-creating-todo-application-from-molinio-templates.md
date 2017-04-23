---
ID: 2216
post_title: >
  Creating Todo application from Molinio
  templates
author: Nemeth
post_date: 2017-04-21 10:00:55
post_excerpt: ""
layout: post
permalink: >
  http://molin.io/creating-todo-application-from-molinio-templates/
published: true
tags: [ ]
categories:
  - Microservices
---

### Introduction
Molinio provides a great ability to create the skeleton of a project (template) using ReactJS, AMQP or REST templates in both JavaScript or TypeScript languages. Besides these projects, we created a feature to give you a fully configured, out-of-the-box RabbitMQ and MongoDB server, if necessary. So, with the help of the Molinio, let us show you how to create a simple TODO application. If you’re busy with reading, you can find the complete project on GitHub.
> **GitHub:**
> app-todo: [link](https://github.com/norbertnemeth/app-todo)
> service-todo-data: [link](https://github.com/norbertnemeth/service-todo-data)
> service-todo-logger: [link](https://github.com/norbertnemeth/service-todo-logger)

>  **Extra:** Open TODO microservice product in Molinio with this productManifest file: [link](https://github.com/jaystack/molinio-productdefinitions/tree/master/Todo)

### First steps
As a first step, lets create a simple TODO applicattion that presents basic CRUD operations extended with filtering between tasks. Go to the `Start Page` and choose the `Select folder and Create project`. Select a folder for your projects, then you can start the creating first template. For this we use React and Redux libraries. So let’s just pick `React Application (TS)` template. Fill the fields as it is seen below:


![enter image description here](http://image.prntscr.com/image/aeea8d5eed94448c8f982ea1f6b4c941.png)

By clicking `Add Project` the template starts to form. The process may take a few minutes, because of the npm intallion. After the project is form run it with the `Start` button and select `Watch` option in `Build` button. This feature is going to automatize the build itself. If you click the Earth icon, the Counter application opens in your browser. Let’s open the Visual Studio Code with it’s icon and take a look at project just made.

![enter image description here](http://image.prntscr.com/image/5aeb12c669f94a4f966b5278e75e1d04.png)

This is a well constructed project, in which work can be started. The base of the project is CorpJS (About CorpJS: [link](http://molin.io/the-graceful-microservice-lifecycle/).) Delete these files in src folder: `./component/Counter.tsx`, `./component/Counter.scss`, `./reducers/counter.ts`. Firstly we need to make `actions` and `reducers`. Now place this code into `actionCreators.ts` file.

```javascript
let nextTodoId = 0;  
export const addTodo = (text) => {  
	return {  
		type: 'ADD_TODO',  
	    id: nextTodoId++,  
        text  
    };  
};

export const loadTodo = (text, status) => {  
    return {  
        type: 'LOAD_TODO',  
        id: nextTodoId++,  
        text,  
        status  
    };  
}

export const toggleTodo = (id) => {  
	return {  
		type: 'TOGGLE_TODO',  
        id  
    };  
};  

export const setVisibilityFilter = (filter) => {  
    return {  
        type: 'SET_VISIBILITY_FILTER',  
        filter  
    };  
};  

```

These are the actions we need. Create the new reducers to `./reducers/index.ts`

```javascript
import { combineReducers } from 'redux'  
const todo = (state, action) => {  
	switch (action.type) {  
        case 'ADD_TODO':  
            return {  
                id: action.id,  
                text: action.text,  
                completed: false  
            };  
        case 'LOAD_TODO':  
            return {  
                id: action.id,  
                text: action.text,  
                completed: action.status  
            };  
        case 'TOGGLE_TODO':  
            if (state.id !== action.id) {  
                return state;  
            }  
            return {
	            ...state,
	            completed: !state.completed  
			};  
			default:  
	            return state;
	        }
};  

const todos = (state = [], action) => {  
	console.log("action", action)
	switch (action.type) {  
		case 'ADD_TODO':  
			return [...state, todo(undefined, action)];  
		case 'LOAD_TODO':  
			return [...state, todo(undefined, action)];  
		case 'TOGGLE_TODO':
			return state.map(t => todo(t, action));  
		default:  
			return state;  
		}  
};

const visibilityFilter = (state = 'SHOW_ALL', action) => {  
	switch (action.type) {  
		case 'SET_VISIBILITY_FILTER':  
		return action.filter;  
		default:  
			return state;  
		}
};

export default combineReducers({  
	todos, visibilityFilter  
});  

```

Now we can make the components, three of them to be precise. `AddTodo` contains the form. `TodoList` contains the list of tasks. `Footer` contains a filter, that allows switching between tasks according to there state. Create these files into the `components` folder:

```javascript
//AddTodo.tsx
import {  
	connect  
}  
from 'react-redux';
import * as React from ’react’
import { addTodo } from '../actionCreators'
class AddTodo extends React.Component < any, any > {  
	constructor() {  
		super()
		this.state = {  
			input: ""  
		}
	}
	  
	handleChange(event) {  
		this.setState({  
			input: event.target.value  
		})  
	}
	  
  render() {
    return <div>
      <div className="form-inline">
        <div className="form-group">
          <input type="text" className="form-control" value={this.state.input}
            onChange={this.handleChange.bind(this)} placeholder="New Task" />
        </div>
        <button className="btn btn-primary" onClick={() => {
          this.props.dispatch(addTodo(this.state.input))
          this.setState({ input: "" })
        }}>
          Add Todo
        </button>
      </div>
    </div>
  }

}

export default connect()(AddTodo);

```

```javascript
//TodoList.tsx
import * as React from 'react';
import { connect } from 'react-redux';

import { toggleTodo } from '../actionCreators';

const Todo = ({ onClick, completed, text }) => (
    <li
        onClick={onClick}
        style={{
            textDecoration:
            completed ?
                'line-through' :
                'none'
        }}
        className={
            completed ? 'completed todo' : 'todo'
        }
    >
        {text}
    </li >
);

const TodoList = ({ todos, onTodoClick }) => (
    <ul>
        {todos.map(todo =>
            <Todo
                key={todo.id}
                {...todo}
                onClick={() => onTodoClick(todo.id)}
            />
        )}
    </ul>
);

const getVisibleTodos = (todos, filter) => {
    switch (filter) {
        case 'SHOW_ALL':
            return todos;
        case 'SHOW_COMPLETED':
            return todos.filter(
                t => t.completed
            );
        case 'SHOW_ACTIVE':
            return todos.filter(
                t => !t.completed
            );
    }
}

const mapStateToProps = (state) => {
    return {
        todos: getVisibleTodos(
            state.todos,
            state.visibilityFilter
        )
    };
};
const mapDispatchToProps = (dispatch) => {
    return {
        onTodoClick: (id) => {
            dispatch(toggleTodo(id));
        }
    };
};

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(TodoList);

```

```javascript
//Footer.tsx
import * as React from 'react';
import { connect } from 'react-redux';

import { setVisibilityFilter } from '../actionCreators';

export default class Footer extends React.Component<any, any> {

    render() {
        return <p>
            Show:
      {' '}
            <FilterLink filter='SHOW_ALL'>
                All
      </FilterLink>
            {', '}
            <FilterLink filter='SHOW_ACTIVE'>
                Active
      </FilterLink>
            {', '}
            <FilterLink filter='SHOW_COMPLETED'>
                Completed
      </FilterLink>
        </p>
    }
}

const Link = ({
  active,
    children,
    onClick
  }) => {
    if (active) {
        return <span>{children}</span>;
    }

    return (
        <a href='#'
            onClick={e => {
                e.preventDefault();
                onClick();
            }}
        >
            {children}
        </a>
    );
};

const mapStateProps = (
    state,
    ownProps
) => {
    return {
        active:
        ownProps.filter ===
        state.visibilityFilter
    };
};

const mapDispatchProps = (
    dispatch,
    ownProps
) => {
    return {
        onClick: () => {
            dispatch(
                setVisibilityFilter(ownProps.filter)
            );
        }
    };
};

const FilterLink = connect(
    mapStateProps,
    mapDispatchProps
)(Link);

```
Finnaly setup these as it is below in the `Application.tsx` file:
```javascript
require('./Application.scss')
import * as React from 'react';
import AddTodo from './AddTodo';
import TodoList from './TodoList';
import Footer from './Footer';

export default class Application extends React.Component<any, any> {
  render() {
    return <div className="container">
      <h2>Todo Application</h2>
      <div className="panel panel-success">
        <div className="panel-heading">
          <AddTodo />
        </div>
        <div className="panel-body">
          <TodoList />
        </div>
        <Footer />
      </div>
    </div>
  }
}
```

For the application look nice, insert to following into `Application.scss`.
```javascript
.application {

}

.panel-body {
    min-height: 300px;
    max-height: 300px;
    overflow: auto;
    background: aliceblue;
    font-size: x-large;
}

.panel {
    background-color: #dff0d8;
    width: 350px;
    font-size: large;
}

.todo {
    cursor: pointer;
}

button {
    margin-left: 8px;
}

li {
    list-style-type: circle;
}
```
We need Bootstap CSS, therefore insert to following link into the head of `index.html`.

```javascript
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
```
In the browser you may see the application.

> **Hint:** Use Earth icon in Molinio

![enter image description here](http://image.prntscr.com/image/368b098c0c2c4b89b131cfeccecb1940.png)

### Storing tasks

Refreshing the browser makes tasks disappear. Preventing this let’s male a Rest project. The Rest project stores the tasks to the Mongo database, thus making them available later. So firstly, create a Mongo database named the `infra-todo-mongodb`. 
![enter image description here](http://image.prntscr.com/image/7610dee07d9447a895d672e34d33e524.png)
Create the Rest project too, named `service-todo-data` on the `3001` port. Do not forget to tick MongoDB as dependency.
![enter image description here](http://image.prntscr.com/image/4699597d31f14e35af4c934f98d8caa9.png)
Let’s open the Visual Studio Code with it’s icon and take a look at project just made. We need to two new CorpJS modules. Install them with these commands: `npm i corpjs-endpoints --save`, `npm i corpjs-mongodb --save`. Afterwards import these into the “system.ts” file.

> **Hint:** In Molinio by clicking the console icon, the console opens in the project
 
```javascript
.add('endpoints', Endpoints()).dependsOn({ component: 'config', source: 'endpoints', as: 'config' })
.add('mongodb', MongoDb()).dependsOn('endpoints', { component: 'config', source: 'mongodb', as: 'config' })
```

Add MongoDB to Routers dependencies.
```javascript
.add('router', Router()).dependsOn('config', 'logger', 'app', 'mongodb')
```

Add these to complete the config file (./config/default.js)
```javascript
mongodb: {
    db: "todo"
},
endpoints: {
    endpointsFilePath: "system-endpoints.json"
}
```

Next up “Router.ts”. Add mongodb to the Deps interface.
```javascript
interface Deps {
  config: any
  logger: winston.LoggerInstance
  app: express.Application
  mongodb: any
  rabbitSender: any
}
```

Create a MongoDB collection in the start function and insert the endpoints to the code after the userCollecton variable.
```javascript
const usersCollection = deps.mongodb.collection('TodoList')
deps.app.get('/set/newTodo/:name', (req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*')
  usersCollection.insertOne({ "Name": req.params['name'], "Completed": false })
  res.sendStatus(200)
})

deps.app.get('/set/ready/:name/:status', (req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*')
  try {
    usersCollection.updateOne(
      { "Name": req.params['name'] },
      { $set: { "Completed": req.params['status'] } }
    );
  } catch (e) {
    console.log(e)
  }
  res.sendStatus(200)
})

deps.app.get('/get/todos', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE')
  res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,contenttype')
  usersCollection.find().toArray()
    .then(results => {
      res.setHeader('Content-Type', 'application/json');
      res.json(results)
    })
    .catch(err => res.sendStatus(500))
})
```

As the last step, use these endpoints in the `app-todo` project. Insert these codes after the `ADD_TODO` and `TOGGLE_TODO` events:
```javascript
request.get('http://localhost:3001/set/ready/' + state.text + "/" + !state.completed)  //TOGLE_TODO
request.get('http://localhost:3001/set/newTodo/' + action.text)  //ADD_TODO
```
Put this code to `index.tsx` file. When the application starts, this code will load in tasks from the database.
```javascript
request('http://localhost:3001/get/todos', function(error, response, body) {  
	if (error) return
	const todoList = JSON.parse(body) todoList.map((item, idx) => {  
		store.dispatch(loadTodo(item.Name, item.Completed))  
	})  
});  
```

Done! Now every modification will be saved to the database.

### Saving changes into a history file
The next project will save all the incoming messages into the history file. The type of this project is Amqp and it requires a RabbitMQ server. Firstly, create a RabbitMQ server named `infra-todo-rabbitmq`.
![enter image description here](http://image.prntscr.com/image/2701983e4a194e8b98ac8704d2bb6b07.png)

After the server is done, make an Amqp project:
![enter image description here](http://image.prntscr.com/image/86f5a9fd4a8e47c7b27a6ca36f190703.png)

Modify messaging parameters in the config file, to this:
```javascript
messaging: {
	requestQueue: 'requests'  
}
```
Create a simple function into the `Consumer.ts` file. This function will create the history file if it does not exist.
```javascript
async function investigateFileLocation() {  
	const exists = fs.existsSync('./history.txt') if (!exists) {  
		fs.closeSync(fs.openSync('./history.txt', 'w'));  
	}
}
```

Use this in the Start function.
```javascript
	await investigateFileLocation()
```

Modify these rows:
```javascript
  // await deps.channel.assertExchange(deadLetterExchange, 'topic', { durable: true })
  await deps.channel.assertQueue(requestQueue)
```
Implement a message save function.
 > If necessary install “moment” module. “npm i moment --save” 

```javascript
	fs.appendFileSync('./history.txt', moment().format('llll') + ' - ' + request.msg + '\r\n')  
```

We need this module: `corpjs-amqp` (`npm i corpjs-amqp --save`). When any of the endpoints are called, it sends a message to Rabbit. Create a file named `RabbitSender.ts` in `service-todo-data` project. 
```javascript
//RabbitSender.ts
export default function RabbitSender() {
  return {
    async start({ config, rabbitChannel: channel, logger }) {
      return {
        send: async function send(message: string) {
          const loggerQueueName = (config.messaging && config.messaging.loggerRequestQueueName) || 'requests'
          if (channel) {
            try {
              await channel.assertQueue(loggerQueueName)
              await channel.sendToQueue(loggerQueueName, new Buffer(JSON.stringify({"msg": message})))
            } catch (err) {
              logger.warn(err) // system shouldn't stop if rabbitmq is down
            }
          }
        }
      }
    }
  }
}
```

Add these in the `system.ts` file:
```javascript
  .add('rabbitConn', Amqp.Connection()).dependsOn({ component: 'config', source: 'rabbit', as: 'config' }, 'endpoints').ignorable()
  .add('rabbitChannel', Amqp.Channel()).dependsOn({ component: 'rabbitConn', as: 'connection' }).ignorable()
  .add('rabbitSender', RabbitSender()).dependsOn('config', 'rabbitChannel', 'logger').ignorable()
```

Add `rabbitSender` to the Router dependencies.
```javascript
.add('router', Router()).dependsOn('config', 'logger', 'app', 'mongodb', 'rabbitSender')
```

In the config file set the RabbiMQ permission to:
```javascript
rabbit: {
    connection: {
        username: 'guest',
        password: 'guest'
    }
}
```

Add `mongodb` to the Deps interface in the `Router.ts` file and let's send some message to Rabbit.
For instance:
```javascript
deps.rabbitSender.send('New task: ' + req.params['name'])

const status = req.params['status'] === 'true' ? "complete" : "uncompleted"  
deps.rabbitSender.send(req.params['name'] + ' set to ' + status)

deps.rabbitSender.send('Get todos list!')  
```

Finnaly, set each of the dependencies in the Topology page. Look at the results!
![enter image description here](http://image.prntscr.com/image/78f472b3277c4e46bf82d51a3514510f.png)

![enter image description here](http://image.prntscr.com/image/210a272a35d6470c95216a055146cfcd.png)

![enter image description here](http://image.prntscr.com/image/567a835c043245cab3df0b4187b35fc2.png)
