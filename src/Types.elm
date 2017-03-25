module Types exposing (..)


type alias User =
    { id : String
    , firstName : String
    , lastName : String
    , username : String
    , profilePicture : String
    , age : Int
    }


type alias Credentials =
    { username : String
    , password : String
    }


type alias Context =
    { currentUser : User
    }


type ContextUpdate
    = SetCurrentUser User
    | LogOut
