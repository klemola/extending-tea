module Components.Dashboard exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick)
import HttpBuilder exposing (Error)
import Task exposing (Task)
import Api
import Types.Context as Context exposing (Context, ContextUpdate)
import Components.EditProfile as EditProfile


type View
    = EditProfileView
    | ShowProfileView


type Msg
    = SwitchView View
    | Logout
    | HandleLogoutResponse String
    | NoOp
    | EditProfileMsg EditProfile.Msg


type alias Model =
    { activeView : View
    , editProfileModel : EditProfile.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( editProfileModel, editProfileCmd ) =
            EditProfile.init
    in
        ( { activeView = ShowProfileView
          , editProfileModel = editProfileModel
          }
        , Cmd.map EditProfileMsg editProfileCmd
        )


update : Context -> Msg -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
update context msg model =
    case msg of
        SwitchView view ->
            ( { model | activeView = view }, Cmd.none, Nothing )

        Logout ->
            ( model
            , Task.perform (\_ -> NoOp) HandleLogoutResponse logout
            , Nothing
            )

        HandleLogoutResponse _ ->
            ( fst init, snd init, Just Context.LogOut )

        NoOp ->
            ( model, Cmd.none, Nothing )

        EditProfileMsg editProfileMsg ->
            let
                ( editProfileModel, editProfileCmd, _ ) =
                    EditProfile.update context editProfileMsg model.editProfileModel
            in
                ( { model | editProfileModel = editProfileModel }, Cmd.none, Nothing )


logout : Task (Error String) String
logout =
    Api.emptyValue
        |> Api.post Api.messageDecoder "/api/logout"
        |> Task.map .data


view : Context -> Model -> Html Msg
view context model =
    div []
        [ navigation
        , activeView context model
        ]


navigation : Html Msg
navigation =
    nav []
        [ button [ onClick (SwitchView ShowProfileView) ] [ text "View profile " ]
        , button [ onClick (SwitchView EditProfileView) ] [ text "Edit profile " ]
        , button [ onClick (Logout) ] [ text "Logout " ]
        ]


activeView : Context -> Model -> Html Msg
activeView context model =
    case model.activeView of
        EditProfileView ->
            App.map EditProfileMsg (EditProfile.view context model.editProfileModel)

        ShowProfileView ->
            showProfileView context


showProfileView : Context -> Html Msg
showProfileView context =
    div []
        [ h1 [] [ text "Profile" ]
        , text context.currentUser.firstName
        ]
