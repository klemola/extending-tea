module Components.Dashboard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (src)
import Html.App as App
import Html.Events exposing (onClick)
import HttpBuilder exposing (Error)
import Task exposing (Task)
import Api
import Types.Context as Context exposing (Context, ContextUpdate)
import Types.User as User exposing (User)
import Components.EditProfile as EditProfile


type View
    = EditProfileView
    | ShowProfileView


type Msg
    = ContextUpdate
    | SwitchView View
    | Logout
    | HandleLogoutResponse String
    | NoOp
    | EditProfileMsg EditProfile.Msg


type alias Model =
    { activeView : View
    , editProfileModel : EditProfile.Model
    }


init : Context -> ( Model, Cmd Msg )
init context =
    let
        ( editProfileModel, editProfileCmd ) =
            EditProfile.init context
    in
        ( { activeView = ShowProfileView
          , editProfileModel = editProfileModel
          }
        , Cmd.map EditProfileMsg editProfileCmd
        )


update : Context -> Msg -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
update context msg model =
    case msg of
        ContextUpdate ->
            contextUpdate context model

        SwitchView view ->
            ( { model | activeView = view }, Cmd.none, Nothing )

        Logout ->
            ( model
            , Task.perform (\_ -> NoOp) HandleLogoutResponse logout
            , Nothing
            )

        HandleLogoutResponse _ ->
            let
                ( initialModel, intialCmd ) =
                    init context
            in
                ( initialModel, intialCmd, Just Context.LogOut )

        NoOp ->
            ( model, Cmd.none, Nothing )

        EditProfileMsg editProfileMsg ->
            let
                ( editProfileModel, editProfileCmd, maybeContextUpdate ) =
                    EditProfile.update context editProfileMsg model.editProfileModel
            in
                ( { model | editProfileModel = editProfileModel }
                , Cmd.map EditProfileMsg editProfileCmd
                , maybeContextUpdate
                )


contextUpdate : Context -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
contextUpdate context model =
    let
        ( editProfileModel, editProfileCmd, _ ) =
            EditProfile.update context EditProfile.ContextUpdate model.editProfileModel
    in
        ( { model
            | editProfileModel = editProfileModel
            , activeView = ShowProfileView
          }
        , Cmd.map EditProfileMsg editProfileCmd
        , Nothing
        )


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
            App.map EditProfileMsg (EditProfile.view model.editProfileModel)

        ShowProfileView ->
            showProfileView context.currentUser


showProfileView : User -> Html Msg
showProfileView user =
    div []
        [ h2 []
            [ text "Profile" ]
        , p []
            [ text (user.firstName ++ " " ++ user.lastName) ]
        , p []
            [ text ("Username: " ++ user.username) ]
        , p []
            [ text ("Age: " ++ (toString user.age)) ]
        , div []
            [ img [ src user.profilePicture ] [] ]
        ]
