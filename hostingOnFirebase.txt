Firebase hosting:
open terminal and run command
firebase init
select existing project, pick firebase project
when asked to use a 'web framework', say no
configure as single page app, say yes
say use build/web as public directory

configure rewrites as follows:
    "rewrites": [
      {
        "source": "/assets/**",
        "destination": "/assets/**"
      },
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]

copy the build.web from the flutter project to the firebaseHosting build/web directory (replacing all)
before building update the version number in index.html: entrypointUrl: "main.dart.js?v=1",
otherwise the browser will cache the old version and not update.
build the build/web version:
flutter build web
to build a web version of the flutter project

when issue to deploy:
firebase deploy