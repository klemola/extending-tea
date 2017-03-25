# An example of extension to The Elm Architecture

## Update

I've had a chance to revise the core idea with Ossi. We improved the implementation, and you can see the results here: [ohanhi/elm-taco](https://github.com/ohanhi/elm-taco)

This example is still relevant in the sense that we use different data in `elm-taco`. User state handling, back-end server and sessions are unique to this repository.

### Jump to...
- **[About](#about)**
 - **[TEA extensions](#tea-extensions)**
 - **[Module structure](#module-structure)**
- **[Requirements](#requirements)**
- **[Usage](#usage)**
- **[Acknowledgments](#acknowledgments)**

## About

>The Elm Architecture is a simple pattern for infinitely nestable components. It is great for modularity, code reuse, and testing. Ultimately, it makes it easy to create complex web apps that stay  healthy as you refactor and add features.
- Description of The Elm Architecture (TEA) from [the official Elm guide](http://guide.elm-lang.org/architecture/).

This repository is an implementation of TEA with modifications. The modifications stem from experience of a commercial real world Elm project.

User management is something that has to be implemented for many (if not most) web applications. Here you'll find a front-end application that has the following functionality:

- Login
- Logout
- Display user information
- Edit user information
- Display a loading message during app initialization
- Display error messages for HTTP failures

The application is accompanied by a mock back-end server to exhibit how to update application state depending on HTTP action results.

### TEA extensions

- add `Context` parameter to  `init`, `update` and `view` function signatures (where applicable)
- add `Maybe ContextUpdate` to the tuple returned by an `update` function (where applicable)
- initialize the application based on whether there's enough data available to build a `Context`

In this example the `Context` contains current user's information. It's created after a successful user authorization and updated during application lifecycle. User data is accessed by multiple components. The motivation for such an extension is to provide data for multiple components without storing the data in the every component's model. One should also be able to update the context deep from the component hierarchy without resetting the whole application. The presence of user data in the context also helps to separate authorized and non-authorized views.

`Context` could also contain other values that should be easily accessed by multiple TEA components, such as notifications or navigation parameters. One could also make partially applied functions available in `Context` if the applied parameters are not very useful deep in the component hierarchy.

### Module structure

```bash
src/
├── Components
│   ├── App.elm
│   ├── Dashboard.elm
│   ├── EditProfile.elm
│   └── Login.elm
├── Decoders.elm
├── Encoders.elm
├── Helpers.elm
├── Main.elm
└── Types.elm
```

```elm
-- App.elm
...
import Components.Dashboard as Dashboard
import Components.Login as Login
import Types exposing (Context, ContextUpdate(..), User)
import Decoders exposing (userDecoder)
```

The Elm Architecture doesn't enforce a rigid module structure. The structure of this repository is result of several iterations in a bigger project (but doesn't contain all of the module types you'd find in such project). It's fairly useful to have separate modules for types that contain type definitions and their encoders/decoders. Components also have their own namespace.

## Requirements

- Elm version 0.18 or greater
  - Build and start scripts require `elm-make` and `elm-package` binaries in `PATH`
- Node version 6.0.0 or greater (may work on Node 5.x but it's not supported)
- NPM version 3.10.0 or greater

## Usage

- install depedencies via `npm install`
 - Elm depedencies will also be automatically installed
- start the application via `npm start`
  - running the command will build the application and start mock server
- during development `npm run build` will rebuild the application (refresh browser to see the changes)

## Acknowledgments

The ideas showcased in this repository are joint work of [Matias Klemola](https://github.com/klemola) and [Ossi Hanhinen](https://github.com/ohanhi). Special thanks to [Futurice](http://futurice.com) for allocating time for the development.
