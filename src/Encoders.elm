module Encoders exposing (..)

import Json.Encode as JsonEncode exposing (Value, object, string)
import Types exposing (..)


encodeUser : User -> Value
encodeUser user =
    object
        [ ( "id", JsonEncode.string user.id )
        , ( "firstName", JsonEncode.string user.firstName )
        , ( "lastName", JsonEncode.string user.lastName )
        , ( "username", JsonEncode.string user.username )
        , ( "profilePicture", JsonEncode.string user.profilePicture )
        , ( "age", JsonEncode.int user.age )
        ]


encodeCredentials : Credentials -> Value
encodeCredentials credentials =
    object
        [ ( "username", string credentials.username )
        , ( "password", string credentials.password )
        ]


empty : Value
empty =
    object []
