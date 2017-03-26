module Components.App exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (style)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (get)
import Components.Dashboard as Dashboard
import Components.Login as Login
import Types exposing (ActiveView(..), Context, ContextUpdate(..), User)
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
            { currentUser = user
            , activeView = ShowProfileView
            }

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
            case ( model.context, model.dashboardModel ) of
                ( Just ctx, Just dbModel ) ->
                    updateDashboard model msg dbModel ctx

                _ ->
                    ( model, Cmd.none )


updateDashboard : Model -> Dashboard.Msg -> Dashboard.Model -> Context -> ( Model, Cmd Msg )
updateDashboard model dashboardMsg dashboardModel context =
    let
        ( updatedModel, dashboardCmd, contextUpdate ) =
            Dashboard.update context dashboardMsg dashboardModel

        changeUserInContext user =
            model.context
                |> Maybe.map
                    (\ctx ->
                        { ctx
                            | currentUser = user
                            , activeView = ShowProfileView
                        }
                    )

        changeViewInContext view =
            model.context
                |> Maybe.map (\ctx -> { ctx | activeView = view })
    in
        case contextUpdate of
            Just (SetCurrentUser user) ->
                ( { model
                    | context = changeUserInContext user
                    , appReady = True
                    , dashboardModel = Just updatedModel
                  }
                , Cmd.map DashboardMsg dashboardCmd
                )

            Just LogOut ->
                init

            Just (ChangeView view) ->
                ( { model
                    | context = changeViewInContext view
                    , dashboardModel = Just updatedModel
                  }
                , Cmd.map DashboardMsg dashboardCmd
                )

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
    case ( model.context, model.dashboardModel ) of
        ( Just ctx, Just dbModel ) ->
            Html.map DashboardMsg (Dashboard.view ctx dbModel)

        _ ->
            Html.map LoginMsg (Login.view model.loginModel)
