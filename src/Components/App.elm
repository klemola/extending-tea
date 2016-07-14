module Components.App exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.App
import Task exposing (Task)
import HttpBuilder exposing (Error)
import Api
import Components.Dashboard as Dashboard
import Components.Login as Login
import Types.User as User exposing (User)
import Types.Context as Context exposing (Context, ContextUpdate(..))


type Msg
    = UpdateContext ContextUpdate
    | SetUser User
    | HandleFailure
    | LoginMsg Login.Msg
    | DashboardMsg Dashboard.Msg


type alias Model =
    { context : Maybe Context
    , loginModel : Login.Model
    , dashboardModel : Maybe Dashboard.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( loginModel, loginCmd ) =
            Login.init
    in
        ( { context = Nothing
          , dashboardModel = Nothing
          , loginModel = loginModel
          }
        , Cmd.batch
            [ Task.perform (\_ -> HandleFailure) SetUser authenticateUser
            , Cmd.map LoginMsg loginCmd
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateContext contextUpdate ->
            updateContext model contextUpdate

        SetUser user ->
            updateContext model (Context.SetCurrentUser user)

        HandleFailure ->
            model ! []

        LoginMsg msg ->
            let
                ( loginModel, loginCmd, contextUpdate ) =
                    Login.update msg model.loginModel
            in
                ( { model
                    | loginModel = loginModel
                  }
                , Cmd.batch
                    (maybeUpdateContext contextUpdate :: [ Cmd.map LoginMsg loginCmd ])
                )

        DashboardMsg msg ->
            model.context
                |> Maybe.map2 (updateDashboard model msg) model.dashboardModel
                |> Maybe.withDefault ( model, Cmd.none )


authenticateUser : Task (Error String) User
authenticateUser =
    Api.get User.decoder "/api/me"
        |> Task.map .data


maybeUpdateContext : Maybe ContextUpdate -> Cmd Msg
maybeUpdateContext contextUpdate =
    case contextUpdate of
        Just update ->
            Task.succeed ()
                |> Task.perform (\_ -> HandleFailure) (\_ -> UpdateContext update)

        Nothing ->
            Cmd.none


updateDashboard : Model -> Dashboard.Msg -> Dashboard.Model -> Context -> ( Model, Cmd Msg )
updateDashboard model dashboardMsg currentModel context =
    let
        ( dashboardModel, dashboardCmd, contextUpdate ) =
            Dashboard.update context dashboardMsg currentModel
    in
        ( { model
            | dashboardModel = Just dashboardModel
          }
        , Cmd.batch
            (maybeUpdateContext contextUpdate :: [ Cmd.map DashboardMsg dashboardCmd ])
        )


updateContext : Model -> ContextUpdate -> ( Model, Cmd Msg )
updateContext model contextUpdate =
    case contextUpdate of
        SetCurrentUser user ->
            let
                context =
                    { currentUser = user }

                ( dashboardModel, dashboardCmd ) =
                    Dashboard.init
            in
                ( { model
                    | context = Just context
                    , dashboardModel = Just dashboardModel
                  }
                , Cmd.map DashboardMsg dashboardCmd
                )

        LogOut ->
            init


view : Model -> Html Msg
view model =
    div [ style [ ( "padding", "0 2rem" ) ] ]
        [ h1 [] [ text "Extending TEA" ]
        , activeView model
        ]


activeView : Model -> Html Msg
activeView model =
    case model.context of
        Just context ->
            case model.dashboardModel of
                Just dashboardModel ->
                    Html.App.map DashboardMsg (Dashboard.view context dashboardModel)

                Nothing ->
                    Debug.crash "Should not be possible"

        Nothing ->
            Html.App.map LoginMsg (Login.view model.loginModel)
