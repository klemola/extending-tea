module Api exposing (post, get, messageDecoder, emptyValue)

import HttpBuilder exposing (..)
import Task exposing (Task)
import Json.Decode exposing (Decoder, (:=), string, object1)
import Json.Encode as JsonEncode exposing (Value)


post : Decoder success -> String -> Value -> Task (Error String) (Response success)
post successDecoder url body =
    url
        |> HttpBuilder.post
        |> withHeader "content-type" "application/json"
        |> withJsonBody body
        |> send (jsonReader successDecoder) (jsonReader errorDecoder)


get : Decoder success -> String -> Task (Error String) (Response success)
get successDecoder url =
    url
        |> HttpBuilder.get
        |> withHeader "Cache-Control" "no-store, must-revalidate, no-cache, max-age=0"
        |> send (jsonReader successDecoder) (jsonReader errorDecoder)


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
