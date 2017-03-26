module Decoders exposing (..)

import Json.Decode exposing (Decoder, string, int)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Types exposing (..)


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "id" string
        |> required "firstName" string
        |> required "lastName" string
        |> required "username" string
        |> required "profilePicture" string
        |> required "age" int


messageDecoder : Decoder String
messageDecoder =
    decode identity
        |> required "message" string


errorDecoder : Decoder String
errorDecoder =
    decode identity
        |> required "error" string
