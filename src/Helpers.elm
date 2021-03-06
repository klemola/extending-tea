module Helpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Http exposing (Error(..))
import Json.Decode exposing (decodeString)
import RemoteData exposing (RemoteData(..), WebData)
import Decoders exposing (errorDecoder)


formatErrorResponse : Error -> String
formatErrorResponse error =
    case error of
        BadUrl text ->
            "Incorrect url"

        BadStatus response ->
            case decodeString errorDecoder response.body of
                Ok text ->
                    text

                Err _ ->
                    "Request failed"

        _ ->
            "Request failed"


errorText : String -> Html msg
errorText content =
    p [ style [ ( "color", "red" ) ] ]
        [ text content ]


errorMessageView : WebData a -> Html msg
errorMessageView response =
    case response of
        Failure error ->
            errorText (formatErrorResponse error)

        _ ->
            text ""
