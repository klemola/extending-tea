module Components.Login exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (type', placeholder)
import Types.Context as Context exposing (Context, ContextUpdate)
import Types.User exposing (User)


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
            ( model, Cmd.none, Nothing )

        HandleResponse user ->
            ( fst init, snd init, Just (Context.SetCurrentUser user) )

        HandleFailure ->
            ( { model | errorMessage = Just "Login failed" }, Cmd.none, Nothing )


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text "Username is \"mycupoftea\" and password is \"hunter2\"" ]
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
