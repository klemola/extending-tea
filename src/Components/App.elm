module Components.App exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (style)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (get)
import Components.Dashboard as Dashboard
import Components.Login as Login
import Types exposing (Context, ContextUpdate(..), User)
import Decoders exposing (userDecoder)


type Msg
    = UserResponse (WebData User)
    | LoginMsg Login.Msg
    | DashboardMsg Dashboard.Msg


type alias Model =
    { context : Maybe Context
    , appReady : Bool
    , loginModel : Login.Model
    , dashboardModel : Maybe Dashboard.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { context = Nothing
      , appReady = False
      , dashboardModel = Nothing
      , loginModel = Login.init
      }
    , authenticateUser
    )


initAuthenticated : User -> ( Model, Cmd Msg )
initAuthenticated user =
    let
        context =
            { currentUser = user }

        ( dashboardModel, dashboardCmd ) =
            Dashboard.init context
    in
        ( { context = Just context
          , appReady = True
          , dashboardModel = Just dashboardModel
          , loginModel = Login.init
          }
        , Cmd.map DashboardMsg dashboardCmd
        )


authenticateUser : Cmd Msg
authenticateUser =
    get "/api/me" UserResponse userDecoder


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserResponse webData ->
            case webData of
                Success user ->
                    initAuthenticated user

                _ ->
                    { model | appReady = True } ! []

        LoginMsg msg ->
            let
                ( updatedModel, loginCmd, contextUpdate ) =
                    Login.update msg model.loginModel
            in
                case contextUpdate of
                    Just (SetCurrentUser user) ->
                        initAuthenticated user

                    _ ->
                        ( { model | loginModel = updatedModel }, Cmd.map LoginMsg loginCmd )

        DashboardMsg msg ->
            model.context
                |> Maybe.map2 (updateDashboard model msg) model.dashboardModel
                |> Maybe.withDefault ( model, Cmd.none )


updateDashboard : Model -> Dashboard.Msg -> Dashboard.Model -> Context -> ( Model, Cmd Msg )
updateDashboard model dashboardMsg dashboardModel context =
    let
        ( updatedModel, dashboardCmd, contextUpdate ) =
            Dashboard.update context dashboardMsg dashboardModel
    in
        case contextUpdate of
            Just (SetCurrentUser user) ->
                ( { model
                    | context = Just { currentUser = user }
                    , appReady = True
                    , dashboardModel = Just updatedModel
                  }
                , Cmd.map DashboardMsg dashboardCmd
                )

            Just LogOut ->
                init

            Nothing ->
                ( { model | dashboardModel = Just updatedModel }, Cmd.map DashboardMsg dashboardCmd )


view : Model -> Html Msg
view model =
    let
        content =
            if model.appReady == True then
                activeView model
            else
                text "Loading..."
    in
        div [ style [ ( "padding", "1rem 2rem" ) ] ]
            [ h1 [] [ text "Extending TEA" ]
            , content
            ]


activeView : Model -> Html Msg
activeView model =
    case model.context of
        Just context ->
            case model.dashboardModel of
                Just dashboardModel ->
                    Html.map DashboardMsg (Dashboard.view context dashboardModel)

                Nothing ->
                    Debug.crash "Should not be possible"

        Nothing ->
            Html.map LoginMsg (Login.view model.loginModel)
