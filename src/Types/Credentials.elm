module Types.Credentials exposing (Credentials, encode)

import Json.Encode as JsonEncode exposing (Value, object, string)


type alias Credentials =
    { username : String
    , password : String
    }


encode : Credentials -> Value
encode credentials =
    object
        [ ( "username", string credentials.username )
        , ( "password", string credentials.password )
        ]
