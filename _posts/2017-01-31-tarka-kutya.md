---
ID: 1942
post_title: Tarka macska
author: lacus
post_date: 2017-01-31 15:01:58
post_excerpt: ""
layout: post
permalink: http://molinio.jaystack.com/tarka-kutya/
published: true
tags:
  - Kutya
  - Tarka
categories:
  - Get started
  - Molinio
  - Tutorials
  - Uncategorized
---
Integer diam ipsum, molestie non pellentesque et, laoreet ac lacus. Curabitur imperdiet semper erat, et tincidunt erat fermentum quis. Sed eros tellus, posuere at facilisis nec, posuere ac eros. Curabitur lacinia vulputate nunc. Ut ac nibh id enim ornare blandit. Pellentesque eget massa vestibulum, commodo lectus in, pulvinar magna. Ut vel nisl et elit dictum laoreet. Quisque gravida vitae tellus et tristique. Aenean eget dapibus nisi. Sed semper lectus libero, et volutpat ligula rhoncus vitae. Nam eget metus at nibh posuere congue id nec magna. Donec semper maximus tellus ultrices iaculis. Mauris luctus faucibus ligula, eget ullamcorper dolor. Cras posuere diam lorem, in efficitur nisl iaculis sit amet. Nam ut ipsum a ipsum posuere pretium eu in purus.

Donec vulputate leo et tellus blandit, porttitor luctus urna commodo. In quam velit, lacinia id arcu vel, placerat fermentum lacus. Integer ullamcorper massa eget massa vehicula tincidunt. Sed imperdiet tellus eu lorem interdum, vel rutrum lacus tincidunt. Curabitur mollis nisl non elit suscipit, quis sagittis risus auctor. Aenean at viverra lorem, pharetra tempor nisi. Etiam dictum eu orci vitae vulputate. Nulla sollicitudin, ante a porta dictum, lorem nibh tristique lorem, non dignissim odio dolor id metus. Integer ac enim porta, condimentum lectus eget, finibus massa. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec in diam id sem blandit mollis. Proin eget tortor a nisi molestie euismod a efficitur magna. Aliquam ut enim sed risus commodo egestas vitae quis nibh. Cras at sem massa.

## Lorem ipsum
~~~
declare namespace Modem {
class M{}
}
declare module &#039;Modem&#039; {
    
    var modem : Modem.M
    export = modem
}
~~~
## Lorem ipsum
~~~
{
  &quot;logger&quot;: {
    &quot;console&quot;: {
      &quot;level&quot;: &quot;debug&quot;,
      &quot;colorize&quot;: true,
      &quot;timestamp&quot;: true
    },
    &quot;molinio&quot;: {
      &quot;level&quot;: &quot;debug&quot;,
      &quot;colorize&quot;: true,
      &quot;timestamp&quot;: true
    }
  },
  &quot;console&quot;: {
    &quot;win32&quot;: {
      &quot;consoleType&quot;: &quot;cmd&quot;
    },
    &quot;linux&quot;: {
      &quot;consoleType&quot;: &quot;xterm&quot;
    },
    &quot;darwin&quot;: {
      &quot;consoleType&quot;: &quot;Terminal&quot;
    }
  }
}
~~~
## Lorem ipsum
~~~
/* aside */

aside {
    padding: 45px 0;

    h3, h2 {
        font-size: 24px;
    }

    section {
        position: relative;
        border: 1px solid $oc-gray-3;
        padding: 20px;
        width: 100%;
        background-color: $white;

        &amp; + section {
            margin-top: 30px;
        }

        *:first-child {
            margin-top: 0;
        } 
        *:last-child {
            margin-bottom: 0;
        }

        &amp;.widget_categories,
        &amp;.shortcode_widget,
        &amp;.related_posts_by_taxonomy {
            ul {
                padding-left: 0;
                list-style-type: none;

                ul {
                    display: none;
                }

                li {
                    padding: {
                        top: 5px;
                        bottom: 5px;
                    }
                    font-size: 13px;
                }

                a {
                    position: relative;
                    left: 0;
                    display: inline-block;
                    padding-left: 0;
                    color: $black;
                    font-weight: bold;
                    @include transition(color 0.222s ease);

                    &amp;:hover {
                        color: $oc-green-8;
                    }

                    &amp;:before {
                        @include icon($fa-var-angle-right);
                        @extend %before-icon;
                        @include transition(left 0.2s ease);
                        position: relative;
                        left: 0;
                    }

                    &amp;:hover:before {
                        left: 2px;
                    }
                }
            }
        }

        &amp;.widget_tag_cloud {
            h2 {
                &amp;:before {
                    @include icon($fa-var-tags);
                    @extend %before-icon;
                }
            }
        }

        &amp;.inverse,
        &amp;.dark,
        &amp;.black {
            border-color: #2E2E2C;
            background-color: #2E2E2C;
            color: $white;
            
            &amp;.widget_categories,
            &amp;.shortcode_widget,
            &amp;.related_posts_by_taxonomy {
                ul a {
                    color: $white;

                    &amp;:hover {
                        color: $oc-green-5;
                    }
                }
            }
        }

        &amp;.gray {
            background-color: $oc-gray-0;
        }

        &amp;.green {
            background-color: $oc-green-9;
            color: $white;
        }
    }

    img {
        max-width: 99%;
        height: auto;
    }
}
~~~
## Lorem ipsum
~~~
// widgets
function jaydata_widgets_init() {
	register_sidebar( array(
		&#039;name&#039;          =&gt; &#039;Blog left sidebar&#039;,
		&#039;id&#039;            =&gt; &#039;blog_left&#039;,
		&#039;before_widget&#039; =&gt; &#039;&lt;section id=&quot;%1$s&quot; class=&quot;%2$s&quot;&gt;&#039;,
		&#039;after_widget&#039;  =&gt; &#039;&lt;/section&gt;&#039;,
		&#039;before_title&#039;  =&gt; &#039;&lt;h2&gt;&#039;,
		&#039;after_title&#039;   =&gt; &#039;&lt;/h2&gt;&#039;,
	) );
	register_sidebar( array(
		&#039;name&#039;          =&gt; &#039;Blog left sidebar - single blogpost&#039;,
		&#039;id&#039;            =&gt; &#039;blog_single_left&#039;,
		&#039;before_widget&#039; =&gt; &#039;&lt;section id=&quot;%1$s&quot; class=&quot;%2$s&quot;&gt;&#039;,
		&#039;after_widget&#039;  =&gt; &#039;&lt;/section&gt;&#039;,
		&#039;before_title&#039;  =&gt; &#039;&lt;h2&gt;&#039;,
		&#039;after_title&#039;   =&gt; &#039;&lt;/h2&gt;&#039;,
	) );
}
add_action( &#039;widgets_init&#039;, &#039;jaydata_widgets_init&#039; );
~~~