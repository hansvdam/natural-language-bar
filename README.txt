Firebase hosting:
create directory firebaseHosting
open terminal and run command
firebase init
select existing project, pick firebase project
when asked to use a 'web framework', say no
configure as single page app, say yes
say use build/web as public directory
copy the build.web from the flutter project to the firebaseHosting build/web directory (replacing all)
when issue in the firebaseHosting-directory:
firebase deploy