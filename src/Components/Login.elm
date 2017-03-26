module Components.Login exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (type_, placeholder, style)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (post)
import Types exposing (Context, ContextUpdate(..), Credentials, User)
import Encoders exposing (encodeCredentials)
import Decoders exposing (userDecoder)
import Helpers exposing (errorMessageView)


type Msg
    = SetUserName String
    | SetPassword String
    | Login
    | HandleResponse (WebData User)


type alias Model =
    { username : String
    , password : String
    , userResponse : WebData User
    }


init : Model
init =
    { username = ""
    , password = ""
    , userResponse = NotAsked
    }


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
update msg model =
    case msg of
        SetUserName username ->
            ( { model | username = username }, Cmd.none, Nothing )

        SetPassword password ->
            ( { model | password = password }, Cmd.none, Nothing )

        Login ->
            let
                credentials =
                    Credentials model.username model.password
            in
                ( model
                , login credentials
                , Nothing
                )

        HandleResponse webData ->
            case webData of
                Success user ->
                    ( init, Cmd.none, Just (SetCurrentUser user) )

                _ ->
                    ( { model | userResponse = webData }, Cmd.none, Nothing )


login : Credentials -> Cmd Msg
login credentials =
    post "/api/login" HandleResponse userDecoder (encodeCredentials credentials)


view : Model -> Html Msg
view model =
    div []
        [ errorMessageView model.userResponse
        , p [] [ text "Username is \"mycupoftea\" and password is \"hunter2\"" ]
        , div [] (loginForm model)
        ]


loginForm : Model -> List (Html Msg)
loginForm model =
    let
        items =
            [ input [ type_ "text", placeholder "Name", onInput SetUserName ] []
            , input [ type_ "password", placeholder "Password", onInput SetPassword ] []
            , button [ onClick Login ] [ text "Submit" ]
            ]
    in
        List.map (\item -> div [] [ item ]) items
