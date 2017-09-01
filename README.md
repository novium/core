# Core

"Core" is aimed to be a central authentication store that stores everything from OAuth authorizations to user profiles. I'm building this mainly as an *excersise* to learn Elixir and Phoenix but also to use it myself, so all the caveats of that apply.

## Features
* Password login
* OAuth authorization server (server side flow // access_token)
* User profiles
* Ueberauth package

## Working on
* Check if already authorize

## TODO
This is currently planned:
* "Social" login (Google, Facebook etc.) 
* Administration interface
* API:s for the former things mentioned
* "Plug n' Play" package so that authentication is easier to set up for phoenix
* Documentation, documentation, and did I say, documentation?
* Rewrite things in a more efficient and less sloppy manner
* OAuth password flow for "trusted" apps*
* OAuth client-side flow

* Maybe not.

## Usage
Run in development mode:

  * Get erlang and elixir by visiting their respective websites
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

** Using this in production is not advised **