module Types.Credentials exposing (Credentials, encode)

import Json.Encode as JsonEncode exposing (Value, object, string)


type alias Credentials =
    { userName : String
    , password : String
    }


encode : Credentials -> Value
encode credentials =
    object
        [ ( "userName", string credentials.userName )
        , ( "password", string credentials.password )
        ]
