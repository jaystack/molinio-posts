---
ID: 2216
post_title: >
  Creating Todo application from Molinio
  templates
author: Norbert Nemeth
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
<h3>Introduction</h3>

Molinio provides a great ability to create the skeleton of a project (template) using ReactJS, AMQP or REST templates in both JavaScript or TypeScript languages. Besides these projects, we created a feature to give you a fully configured, out-of-the-box RabbitMQ and MongoDB server, if necessary. So, with the help of the Molinio, let us show you how to create a simple TODO application. If you’re busy with reading, you can find the complete project on GitHub.

<blockquote>
  <strong>GitHub:</strong>
  app-todo: <a href="https://github.com/norbertnemeth/app-todo">link</a>
  service-todo-data: <a href="https://github.com/norbertnemeth/service-todo-data">link</a>
  service-todo-logger: <a href="https://github.com/norbertnemeth/service-todo-logger">link</a>
  
  <strong>Extra:</strong> Open TODO microservice product in Molinio with this productManifest file: <a href="https://github.com/jaystack/molinio-productdefinitions/tree/master/Todo">link</a>
</blockquote>

<h3>First steps</h3>

As a first step, let's create a simple TODO application that presents basic CRUD operations extended with filtering between tasks. Go to the <code>Start Page</code> and choose the <code>Select folder and Create project</code>. Select a folder for your projects, then you can start the creating first template. For this, we use React and Redux libraries. So let’s just pick <code>React Application (TS)</code> template. Fill the fields as it is seen below:

<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-01.png" alt="enter image description here" />

By clicking <code>Add Project</code> the template starts to form. The process may take a few minutes, because of the npm intallion. After the project form run it with the <code>Start</code> button and select <code>Watch</code> option in <code>Build</code> button. This feature is going to automatize the build itself. If you click the Earth icon, the Counter application opens in your browser. Let’s open the Visual Studio Code with its icon and take a look at project just made.

<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-02.png" alt="enter image description here" />

This is a well-constructed project, in which work can be started. The base of the project is CorpJS (About CorpJS: <a href="http://molin.io/the-graceful-microservice-lifecycle/">link</a>.) Delete these files in src folder: <code>./component/Counter.tsx</code>, <code>./component/Counter.scss</code>, <code>./reducers/counter.ts</code>. Firstly we need to make <code>actions</code> and <code>reducers</code>. Now place this code into <code>actionCreators.ts</code> file.

<pre><code class="javascript">let nextTodoId = 0;  
export const addTodo = (text) =&gt; {  
    return {  
        type: 'ADD_TODO',  
        id: nextTodoId++,  
        text  
    };  
};

export const loadTodo = (text, status) =&gt; {  
    return {  
        type: 'LOAD_TODO',  
        id: nextTodoId++,  
        text,  
        status  
    };  
}

export const toggleTodo = (id) =&gt; {  
    return {  
        type: 'TOGGLE_TODO',  
        id  
    };  
};  

export const setVisibilityFilter = (filter) =&gt; {  
    return {  
        type: 'SET_VISIBILITY_FILTER',  
        filter  
    };  
};  

</code></pre>

These are the actions we need. Create the new reducers to <code>./reducers/index.ts</code>

<pre><code class="javascript">import { combineReducers } from 'redux'  
const todo = (state, action) =&gt; {  
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

const todos = (state = [], action) =&gt; {  
    console.log("action", action)
    switch (action.type) {  
        case 'ADD_TODO':  
            return [...state, todo(undefined, action)];  
        case 'LOAD_TODO':  
            return [...state, todo(undefined, action)];  
        case 'TOGGLE_TODO':
            return state.map(t =&gt; todo(t, action));  
        default:  
            return state;  
        }  
};

const visibilityFilter = (state = 'SHOW_ALL', action) =&gt; {  
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

</code></pre>

Now we can make the components, three of them to be precise. <code>AddTodo</code> contains the form. <code>TodoList</code> contains the list of tasks. <code>Footer</code> contains a filter, that allows switching between tasks according to their state. Create these files into the <code>components</code> folder:

<pre><code class="javascript">//AddTodo.tsx
import {  
    connect  
}  
from 'react-redux';
import * as React from ’react’
import { addTodo } from '../actionCreators'
class AddTodo extends React.Component &lt; any, any &gt; {  
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
    return &lt;div&gt;
      &lt;div className="form-inline"&gt;
        &lt;div className="form-group"&gt;
          &lt;input type="text" className="form-control" value={this.state.input}
            onChange={this.handleChange.bind(this)} placeholder="New Task" /&gt;
        &lt;/div&gt;
        &lt;button className="btn btn-primary" onClick={() =&gt; {
          this.props.dispatch(addTodo(this.state.input))
          this.setState({ input: "" })
        }}&gt;
          Add Todo
        &lt;/button&gt;
      &lt;/div&gt;
    &lt;/div&gt;
  }

}

export default connect()(AddTodo);

</code></pre>

<pre><code class="javascript">//TodoList.tsx
import * as React from 'react';
import { connect } from 'react-redux';

import { toggleTodo } from '../actionCreators';

const Todo = ({ onClick, completed, text }) =&gt; (
    &lt;li
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
    &gt;
        {text}
    &lt;/li &gt;
);

const TodoList = ({ todos, onTodoClick }) =&gt; (
    &lt;ul&gt;
        {todos.map(todo =&gt;
            &lt;Todo
                key={todo.id}
                {...todo}
                onClick={() =&gt; onTodoClick(todo.id)}
            /&gt;
        )}
    &lt;/ul&gt;
);

const getVisibleTodos = (todos, filter) =&gt; {
    switch (filter) {
        case 'SHOW_ALL':
            return todos;
        case 'SHOW_COMPLETED':
            return todos.filter(
                t =&gt; t.completed
            );
        case 'SHOW_ACTIVE':
            return todos.filter(
                t =&gt; !t.completed
            );
    }
}

const mapStateToProps = (state) =&gt; {
    return {
        todos: getVisibleTodos(
            state.todos,
            state.visibilityFilter
        )
    };
};
const mapDispatchToProps = (dispatch) =&gt; {
    return {
        onTodoClick: (id) =&gt; {
            dispatch(toggleTodo(id));
        }
    };
};

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(TodoList);

</code></pre>

<pre><code class="javascript">//Footer.tsx
import * as React from 'react';
import { connect } from 'react-redux';

import { setVisibilityFilter } from '../actionCreators';

export default class Footer extends React.Component&lt;any, any&gt; {

    render() {
        return &lt;p&gt;
            Show:
      {' '}
            &lt;FilterLink filter='SHOW_ALL'&gt;
                All
      &lt;/FilterLink&gt;
            {', '}
            &lt;FilterLink filter='SHOW_ACTIVE'&gt;
                Active
      &lt;/FilterLink&gt;
            {', '}
            &lt;FilterLink filter='SHOW_COMPLETED'&gt;
                Completed
      &lt;/FilterLink&gt;
        &lt;/p&gt;
    }
}

const Link = ({
  active,
    children,
    onClick
  }) =&gt; {
    if (active) {
        return &lt;span&gt;{children}&lt;/span&gt;;
    }

    return (
        &lt;a href='#'
            onClick={e =&gt; {
                e.preventDefault();
                onClick();
            }}
        &gt;
            {children}
        &lt;/a&gt;
    );
};

const mapStateProps = (
    state,
    ownProps
) =&gt; {
    return {
        active:
        ownProps.filter ===
        state.visibilityFilter
    };
};

const mapDispatchProps = (
    dispatch,
    ownProps
) =&gt; {
    return {
        onClick: () =&gt; {
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

</code></pre>

Finally setup these as it is below in the <code>Application.tsx</code> file:

<pre><code class="javascript">require('./Application.scss')
import * as React from 'react';
import AddTodo from './AddTodo';
import TodoList from './TodoList';
import Footer from './Footer';

export default class Application extends React.Component&lt;any, any&gt; {
  render() {
    return &lt;div className="container"&gt;
      &lt;h2&gt;Todo Application&lt;/h2&gt;
      &lt;div className="panel panel-success"&gt;
        &lt;div className="panel-heading"&gt;
          &lt;AddTodo /&gt;
        &lt;/div&gt;
        &lt;div className="panel-body"&gt;
          &lt;TodoList /&gt;
        &lt;/div&gt;
        &lt;Footer /&gt;
      &lt;/div&gt;
    &lt;/div&gt;
  }
}
</code></pre>

For the application look nice, insert to following into <code>Application.scss</code>.

<pre><code class="javascript">.application {

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
</code></pre>

We need Bootstap CSS, therefore insert to following link into the head of <code>index.html</code>.

<pre><code class="javascript">&lt;link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"&gt;
</code></pre>

A browser you may see the application.

<blockquote>
  <strong>Hint:</strong> Use Earth icon in Molinio
</blockquote>

<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-03.png" alt="enter image description here" />

<h3>Storing tasks</h3>

Refreshing the browser makes tasks disappear. Preventing this let’s male a Rest project. The Rest project stores the tasks to the Mongo database, thus making them available later. So firstly, create a Mongo database named the <code>infra-todo-mongodb</code>. 
<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-04.png" alt="enter image description here" />
Create the Rest project too, named <code>service-todo-data</code> on the <code>3001</code> port. Do not forget to tick MongoDB as dependency.
<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-05.png" alt="enter image description here" />
Let’s open the Visual Studio Code with it’s icon and take a look at project just made. We need to two new CorpJS modules. Install them with these commands: <code>npm i corpjs-endpoints --save</code>, <code>npm i corpjs-mongodb --save</code>. Afterwards import these into the “system.ts” file.

<blockquote>
  <strong>Hint:</strong> In Molinio by clicking the console icon, the console opens in the project
</blockquote>

<pre><code class="javascript">.add('endpoints', Endpoints()).dependsOn({ component: 'config', source: 'endpoints', as: 'config' })
.add('mongodb', MongoDb()).dependsOn('endpoints', { component: 'config', source: 'mongodb', as: 'config' })
</code></pre>

Add MongoDB to Routers dependencies.

<pre><code class="javascript">.add('router', Router()).dependsOn('config', 'logger', 'app', 'mongodb')
</code></pre>

Add these to complete the config file (./config/default.js)

<pre><code class="javascript">mongodb: {
    db: "todo"
},
endpoints: {
    endpointsFilePath: "system-endpoints.json"
}
</code></pre>

Next up “Router.ts”. Add mongodb to the Deps interface.

<pre><code class="javascript">interface Deps {
  config: any
  logger: winston.LoggerInstance
  app: express.Application
  mongodb: any
  rabbitSender: any
}
</code></pre>

Create a MongoDB collection in the start function and insert the endpoints to the code after the userCollecton variable.

<pre><code class="javascript">const usersCollection = deps.mongodb.collection('TodoList')
deps.app.get('/set/newTodo/:name', (req, res, next) =&gt; {
  res.setHeader('Access-Control-Allow-Origin', '*')
  usersCollection.insertOne({ "Name": req.params['name'], "Completed": false })
  res.sendStatus(200)
})

deps.app.get('/set/ready/:name/:status', (req, res, next) =&gt; {
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

deps.app.get('/get/todos', (req, res) =&gt; {
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE')
  res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,contenttype')
  usersCollection.find().toArray()
    .then(results =&gt; {
      res.setHeader('Content-Type', 'application/json');
      res.json(results)
    })
    .catch(err =&gt; res.sendStatus(500))
})
</code></pre>

As the last step, use these endpoints in the <code>app-todo</code> project. Insert these codes after the <code>ADD_TODO</code> and <code>TOGGLE_TODO</code> events:

<pre><code class="javascript">request.get('http://localhost:3001/set/ready/' + state.text + "/" + !state.completed)  //TOGLE_TODO
request.get('http://localhost:3001/set/newTodo/' + action.text)  //ADD_TODO
</code></pre>

Put this code to <code>index.tsx</code> file. When the application starts, this code will load in tasks from the database.

<pre><code class="javascript">request('http://localhost:3001/get/todos', function(error, response, body) {  
    if (error) return
    const todoList = JSON.parse(body) todoList.map((item, idx) =&gt; {  
        store.dispatch(loadTodo(item.Name, item.Completed))  
    })  
});  
</code></pre>

Done! Now every modification will be saved to the database.

<h3>Saving changes into a history file</h3>

The next project will save all the incoming messages into the history file. The type of this project is Amqp and it requires a RabbitMQ server. Firstly, create a RabbitMQ server named <code>infra-todo-rabbitmq</code>.
<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-06.png" alt="enter image description here" />

After the server is done, make an Amqp project:
<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-07.png" alt="enter image description here" />

Modify messaging parameters in the config file, to this:

<pre><code class="javascript">messaging: {
    requestQueue: 'requests'  
}
</code></pre>

Create a simple function into the <code>Consumer.ts</code> file. This function will create the history file if it does not exist.

<pre><code class="javascript">async function investigateFileLocation() {  
    const exists = fs.existsSync('./history.txt') if (!exists) {  
        fs.closeSync(fs.openSync('./history.txt', 'w'));  
    }
}
</code></pre>

Use this in the Start function.

<pre><code class="javascript">    await investigateFileLocation()
</code></pre>

Modify these rows:

<pre><code class="javascript">  // await deps.channel.assertExchange(deadLetterExchange, 'topic', { durable: true })
  await deps.channel.assertQueue(requestQueue)
</code></pre>

Implement a message save function.

<blockquote>
  If necessary install “moment” module. “npm i moment --save”
</blockquote>

<pre><code class="javascript">    fs.appendFileSync('./history.txt', moment().format('llll') + ' - ' + request.msg + 'rn')  
</code></pre>

We need this module: <code>corpjs-amqp</code> (<code>npm i corpjs-amqp --save</code>). When any of the endpoints are called, it sends a message to Rabbit. Create a file named <code>RabbitSender.ts</code> in <code>service-todo-data</code> project.

<pre><code class="javascript">//RabbitSender.ts
export default function RabbitSender() {
  return {
    async start({ config, rabbitChannel: channel, logger }) {
      return {
        send: async function send(message: string) {
          const loggerQueueName = (config.messaging &amp;&amp; config.messaging.loggerRequestQueueName) || 'requests'
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
</code></pre>

Add these in the <code>system.ts</code> file:

<pre><code class="javascript">  .add('rabbitConn', Amqp.Connection()).dependsOn({ component: 'config', source: 'rabbit', as: 'config' }, 'endpoints').ignorable()
  .add('rabbitChannel', Amqp.Channel()).dependsOn({ component: 'rabbitConn', as: 'connection' }).ignorable()
  .add('rabbitSender', RabbitSender()).dependsOn('config', 'rabbitChannel', 'logger').ignorable()
</code></pre>

Add <code>rabbitSender</code> to the Router dependencies.

<pre><code class="javascript">.add('router', Router()).dependsOn('config', 'logger', 'app', 'mongodb', 'rabbitSender')
</code></pre>

In the config file set the RabbiMQ permission to:

<pre><code class="javascript">rabbit: {
    connection: {
        username: 'guest',
        password: 'guest'
    }
}
</code></pre>

Add <code>mongodb</code> to the Deps interface in the <code>Router.ts</code> file and let's send some message to Rabbit.
For instance:

<pre><code class="javascript">deps.rabbitSender.send('New task: ' + req.params['name'])

const status = req.params['status'] === 'true' ? "complete" : "uncompleted"  
deps.rabbitSender.send(req.params['name'] + ' set to ' + status)

deps.rabbitSender.send('Get todos list!')  
</code></pre>

Finnaly, set each of the dependencies in the Topology page. Look at the results!
<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-08.png" alt="enter image description here" />

<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-09.png" alt="enter image description here" />

<img src="https://raw.githubusercontent.com/jaystack/molinio-posts/master/_media/todo-10.png" alt="enter image description here" />
