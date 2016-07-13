module Components.EditProfile exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Types.Context exposing (Context, ContextUpdate)
import Types.User exposing (User)


type Msg
    = UpdateContext Context
    | Submit User
    | HandleResponse User
    | HandleFailure


type alias Model =
    { profileEdit : Maybe User
    , errorMessage : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { profileEdit = Nothing
      , errorMessage = Nothing
      }
    , Cmd.none
    )


update : Context -> Msg -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
update context msg model =
    case msg of
        UpdateContext context ->
            ( { model | profileEdit = Just context.currentUser }, Cmd.none, Nothing )

        Submit user ->
            ( { model | profileEdit = Nothing }, Cmd.none, Nothing )

        HandleResponse user ->
            ( { model | errorMessage = Nothing }, Cmd.none, Nothing )

        HandleFailure ->
            ( { model | errorMessage = Just "Something went wrong" }, Cmd.none, Nothing )


view : Context -> Model -> Html Msg
view context model =
    div []
        [ h1 [] [ text "Edit Profile" ]
        , text context.currentUser.firstName
        ]
