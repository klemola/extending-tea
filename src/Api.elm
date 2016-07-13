module Api exposing (post, messageDecoder, emptyValue)

import HttpBuilder exposing (..)
import Task exposing (Task)
import Json.Decode exposing (Decoder, (:=), string, object1)
import Json.Encode as JsonEncode exposing (Value)


apiCall : (String -> RequestBuilder) -> Decoder error -> Decoder success -> String -> Value -> Task (Error error) (Response success)
apiCall useMethod errorDecoder successDecoder url body =
    url
        |> useMethod
        |> withHeader "content-type" "application/json"
        |> withJsonBody body
        |> send (jsonReader successDecoder) (jsonReader errorDecoder)


post : Decoder success -> String -> Value -> Task (Error String) (Response success)
post =
    apiCall HttpBuilder.post errorDecoder


errorDecoder : Decoder String
errorDecoder =
    object1 identity
        ("error" := string)


messageDecoder : Decoder String
messageDecoder =
    object1 identity
        ("message" := string)


emptyValue : Value
emptyValue =
    JsonEncode.object []
