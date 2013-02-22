Deployment-System
=================

Automated internal tools, usage, and general information
<pre>
                                                                            ,aa,       ,aa
                                                                           d"  "b    ,d",`b
                                                                         ,dP a  "b,ad8' 8 8
                                                                         d8' 8  ,88888a 8 8
                                                                        d8baa8ba888888888a8
                                                                     ,ad888888888YYYY888YYY,
                                                                  ,a888888888888"   "8P"  "b
                                                              ,aad8888tt,8888888b (0 `8, 0 8
                          ____________________________,,aadd888ttt8888ttt"8"I  "Yb,   `Ya  8
                    ,aad8888b888888aab8888888888b,     ,aatPt888ttt8888tt 8,`b,   "Ya,. `"aP
                ,ad88tttt8888888888888888888888888ttttt888ttd88888ttt8888tt,t "ba,.  `"`d888
             ,d888tttttttttttttt888888888888888888888888ttt8888888888ttt888ttt,   "a,   `88'
            a888tttttttttttttttttttttttttt8888888888888ttttt88888ttt888888888tt,    `""8"'
           d8P"' ,tttttttttttttttttttttttttttttttttt88tttttt888tttttttt8a"8888ttt,   ,8'
          d8tb  " ,tt"  ""tttttttttttttttttttttttttttttttttt88ttttttttttt, Y888tt"  ,8'
          88tt)              "t" ttttt" """  """    "" tttttYttttttttttttt, " 8ttb,a8'
          88tt                    `"b'                  ""t'ttttttttttt"t"t   t taP"
          8tP                       `b                       ,tttttt' " " "tt, ,8"
         (8tb  b,                    `b,                 a,  tttttt'        ""dP'
         I88tb `8,                    `b                d'   tttttt        ,aP"
         8888tb `8,                   ,P               d'    "tt "t'    ,a8P"
        I888ttt, "b                  ,8'              ,8       "tt"  ,d"d"'
       ,888tttt'  8b               ,dP""""""""""""""""Y8        tt ,d",d'
     ,d888ttttP  d"8b            ,dP'                  "b,      "ttP' d'
   ,d888ttttPY ,d' dPb,        ,dP'                      "b,     t8'  8
  d888tttt8" ,d" ,d"  8      ,d"'                         `b     "P   8
 d888tt88888d" ,d"  ,d"    ,d"                             8      I   8
d888888888P' ,d"  ,d"    ,d"                               8      I   8
88888888P' ,d"   (P'    d"                                 8      8   8
"8P"'"8   ,8'    Ib    d"                                  Y      8   8
      8   d"     `8    8                                   `b     8   Y
      8   8       8,   8,                                   8     Y   `b
      8   Y,      `b   `b                                   Y     `b   `b
      Y,   "ba,    `b   `b,                                 `b     8,   `"ba,
       "b,   "8     `b    `""b                               `b     `Yaa,adP'
         """""'      `baaaaaaP                                `YaaaadP"'


</pre>
The goal of the deployment is to automate all tasks related to deploying code and rolling back code without more 
than a single step for each task (deploying and rolling back).

Code deployments are generally done on Tuesday's at 2 PM.  All developers who have committed code for deployment 
must be present at the following Google Hangout:

https://plus.google.com/u/0/events/cf6or2mo6bjtroefbr161dgvrhc?authkey=CPOk0-mCndqSMg

Deployment System Overview
=================
* Projects must live in a GIT repository (github)
* Once a project is "ready" for release, the developer must tag the release using the following convention (b1, b2, etc)
> If you are tagging the build, you are also taking responsibility to be on call until the release is deemed stable by Operations

* The project must then be pushed to staging to quality acceptance
* The project will then be pushed to production once its approved for release

First Deployment Ever
=================
* If this is your first time deploying using this system, you will need a user account created on the deployment server 

> You can contact: so@so.com to get your account created
> 
> Once you have credentials, either create a new SSH key on your profile or use an existing one.  It doesn't matter so long as it is linked to you github.com account
>
> You can expect a talk about releasing to production from a Sr. Engineer

First Application/Project Deployment
=================
* If this is the first time a particular project or application will be deployed, you must work with a Sr. Engineer to have a deployment recipe created and have your project configured on the deployment server.

How to deploy
=================
* Once you deem your application worthy of a release, you must tag it: `git tag -a b1 -m "My First tag"`
* The tag name ALWAYS is the letter b (for build) plus the next tag number.  You can find the next tag by either looking on github or by running `git tag`
* Don't forget to push your tag to repository or you won't be able to deploy to staging or production.  You can push a single tag by running `git push origin b1` Assuming you are pushing to origin and the tag name is b1
* If you have a lot of tags, you can push them all by running `git push origin --tags` Assuming the remote repo is origin.  Regardless of how many tags you push to the repository, they must all follow convention and you will release each tag into staging and production individually.
* Once you have pushed your tag and wish to release, you must go to the Software Development Releases Group on Yammer and correctly add your request.  Review the info tab on the group.


How does it all work?
=================
A copy of the project is maintained on the deployment server.  When you run the deployment, Capistrano will communicate with the configured servers via SSH to execute the commands configured in the deployment recipe.

The commands are basically telling the server to checkout the correct requested git tag from github and executing any other tasks like running a SQL alter script.
