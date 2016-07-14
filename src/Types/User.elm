module Types.User exposing (User, decoder)

import Json.Decode exposing (Decoder, (:=), int, string, object6)


type alias User =
    { id : String
    , firstName : String
    , lastName : String
    , username : String
    , profilePicture : String
    , age : Int
    }


decoder : Decoder User
decoder =
    object6 User
        ("id" := string)
        ("firstName" := string)
        ("lastName" := string)
        ("userName" := string)
        ("profilePicture" := string)
        ("age" := int)
