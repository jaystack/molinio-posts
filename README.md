# molinio-posts

## Howto

### Create/edit posts

To create a new post, place a markdown (.md) file to \_posts folder, for scheme see below. Github sends the committed posts to molinio site wia webhook.

To edit existing posts, open its markdown file in text editor the post's markdown file (or use github edit this file function), after commit github sends the changes to molinio website.

## Post schema

~~~
  ---
  post_title: The title
  author: Ben
  post_date: 2017-01-31 15:37:58
  post_excerpt: ""
  layout: post
  permalink: >
    http://molin.io/loremloremlorem/
  published: true
  tags:
    - Untagged
  categories:
    - Uncategorized
  ---
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ultrices nunc sit amet ipsum tempor efficitur. Sed a condimentum libero, in ultrices ante. Nulla facilisi. Integer fermentum consectetur lacinia. Etiam tempus euismod nulla, ut volutpat purus dictum a. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Curabitur a lobortis neque, ac gravida enim. Nulla tempus magna ut consectetur feugiat. Phasellus posuere, massa vitae placerat pharetra, dolor diam tincidunt nulla, sit amet aliquam massa diam eget lectus. Morbi eu tortor eu magna pellentesque luctus. Duis iaculis, nisi nec ultrices lobortis, arcu erat auctor
~~~

## Markdown Cheatsheet

[Mastering Markdown](https://guides.github.com/features/mastering-markdown/)
