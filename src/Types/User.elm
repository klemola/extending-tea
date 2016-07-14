module Types.User exposing (User, encode, decoder)

import Json.Decode as JsonDecode exposing (Decoder, (:=))
import Json.Encode as JsonEncode exposing (Value)


type alias User =
    { id : String
    , firstName : String
    , lastName : String
    , username : String
    , profilePicture : String
    , age : Int
    }


encode : User -> Value
encode user =
    JsonEncode.object
        [ ( "id", JsonEncode.string user.id )
        , ( "firstName", JsonEncode.string user.firstName )
        , ( "lastName", JsonEncode.string user.lastName )
        , ( "username", JsonEncode.string user.username )
        , ( "profilePicture", JsonEncode.string user.profilePicture )
        , ( "age", JsonEncode.int user.age )
        ]


decoder : Decoder User
decoder =
    JsonDecode.object6 User
        ("id" := JsonDecode.string)
        ("firstName" := JsonDecode.string)
        ("lastName" := JsonDecode.string)
        ("username" := JsonDecode.string)
        ("profilePicture" := JsonDecode.string)
        ("age" := JsonDecode.int)
