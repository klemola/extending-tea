module Types.User exposing (User, decoder)

import Json.Decode exposing (Decoder, (:=), int, string, object5)


type alias User =
    { firstName : String
    , lastName : String
    , username : String
    , profilePicture : String
    , age : Int
    }


decoder : Decoder User
decoder =
    object5 User
        ("firstName" := string)
        ("lastName" := string)
        ("userName" := string)
        ("profilePicture" := string)
        ("age" := int)
