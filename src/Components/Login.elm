module Components.Login exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (type', placeholder, style)
import HttpBuilder exposing (Error)
import Task exposing (Task)
import Api
import Types.Context as Context exposing (Context, ContextUpdate)
import Types.User as User exposing (User)
import Types.Credentials as Credentials exposing (Credentials)


type Msg
    = SetUserName String
    | SetPassword String
    | Login
    | HandleResponse User
    | HandleFailure


type alias Model =
    { userName : String
    , password : String
    , errorMessage : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { userName = ""
      , password = ""
      , errorMessage = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
update msg model =
    case msg of
        SetUserName userName ->
            ( { model | userName = userName }, Cmd.none, Nothing )

        SetPassword password ->
            ( { model | password = password }, Cmd.none, Nothing )

        Login ->
            let
                credentials =
                    Credentials model.userName model.password
            in
                ( model
                , Task.perform (\_ -> HandleFailure) HandleResponse (login credentials)
                , Nothing
                )

        HandleResponse user ->
            ( fst init, snd init, Just (Context.SetCurrentUser user) )

        HandleFailure ->
            ( { model | errorMessage = Just "Login failed" }, Cmd.none, Nothing )


login : Credentials -> Task (Error String) User
login credentials =
    Credentials.encode credentials
        |> Api.post User.decoder "/api/login"
        |> Task.map .data


view : Model -> Html Msg
view model =
    div []
        [ p [ style [ ( "color", "red" ) ] ]
            [ text (Maybe.withDefault "" model.errorMessage) ]
        , p [] [ text "Username is \"mycupoftea\" and password is \"hunter2\"" ]
        , div [] (loginForm model)
        ]


loginForm : Model -> List (Html Msg)
loginForm model =
    let
        items =
            [ input [ type' "text", placeholder "Name", onInput SetUserName ] []
            , input [ type' "password", placeholder "Password", onInput SetPassword ] []
            , button [ onClick Login ] [ text "Submit" ]
            ]
    in
        List.map (\item -> div [] [ item ]) items
