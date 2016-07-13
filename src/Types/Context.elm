module Types.Context exposing (Context, ContextUpdate(..))

import Types.User exposing (User)


type alias Context =
    { currentUser : User
    }


type ContextUpdate
    = SetCurrentUser User
    | LogOut
