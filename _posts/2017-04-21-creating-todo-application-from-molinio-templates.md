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
###Introduction
In Molinio, we can build our own microservices application. With help of templates we can create projects that use React, Amqp and Rest library in a few moments, in JavaScript and TypeScript languages. In addition we may create RabbitMq and MongoDB servers, if necessary. With Molinio we create a simple TODO application. The finished projects can be found in the GitHub links below:
> link:
> links:
> inks:

###First steps
As a first step, lets create a simple TODO applicattion that presents basic CRUD operations extended with filtering between tasks. Go to the „Start Page” and choose the „Select folder and Create project”. Select a folder for your projects, then you can start the creating first template. For this we use React and Redux libraries. So let’s just pick „React Application (TS)” template. Fill the fields as it is seen below:


![enter image description here](http://image.prntscr.com/image/aeea8d5eed94448c8f982ea1f6b4c941.png)

By clicking „Add Project” the template starts to form. The process may take a few minutes, because of the npm intallion. After the project is form run it with the „Start” button and select „Watch” option in „Build” button. This feature is going to automatize the build itself. If you click the Earth icon, the Counter application opens in your browser. Let’s open the Visual Studio Code with it’s icon and take a look at project just made.

![enter image description here](http://image.prntscr.com/image/5aeb12c669f94a4f966b5278e75e1d04.png)

This is a well constructed project, in which work can be started. The base of the project is CorpJS (About CorpJS: http://molin.io/the-graceful-microservice-lifecycle/.) Delete these files in src folder: „./component/Counter.tsx, ./component/Counter.scss, ./reducers/counter.ts”. Firstly we need to make „actions” and „reducers”. Now place this code into „actionCreators.ts” file.

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
