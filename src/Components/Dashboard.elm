module Components.Dashboard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (post)
import Types exposing (Context, ContextUpdate(..), User)
import Decoders exposing (messageDecoder)
import Encoders
import Components.EditProfile as EditProfile


type View
    = EditProfileView
    | ShowProfileView


type Msg
    = SwitchView View
    | Logout
    | HandleLogoutResponse (WebData String)
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
        SwitchView view ->
            ( { model | activeView = view }, Cmd.none, Nothing )

        Logout ->
            ( model
            , logout
            , Nothing
            )

        HandleLogoutResponse webData ->
            let
                ( initialModel, intialCmd ) =
                    init context
            in
                case webData of
                    Success _ ->
                        ( initialModel, intialCmd, Just LogOut )

                    _ ->
                        ( model, Cmd.none, Nothing )

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


logout : Cmd Msg
logout =
    post "/api/logout" HandleLogoutResponse messageDecoder Encoders.empty


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
            Html.map EditProfileMsg (EditProfile.view model.editProfileModel)

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
