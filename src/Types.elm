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
    , activeView : ActiveView
    }


type ContextUpdate
    = SetCurrentUser User
    | LogOut
    | ChangeView ActiveView


type ActiveView
    = UnauthorizedView
    | EditProfileView
    | ShowProfileView
