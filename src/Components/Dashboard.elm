module Components.Dashboard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (post)
import Types exposing (ActiveView(..), Context, ContextUpdate(..), User)
import Decoders exposing (messageDecoder)
import Encoders
import Components.EditProfile as EditProfile
import Helpers exposing (errorText)


type Msg
    = SetView ActiveView
    | Logout
    | HandleLogoutResponse (WebData String)
    | EditProfileMsg EditProfile.Msg


type alias Model =
    { editProfileModel : EditProfile.Model
    }


init : Context -> ( Model, Cmd Msg )
init context =
    let
        ( editProfileModel, editProfileCmd ) =
            EditProfile.init context
    in
        ( { editProfileModel = editProfileModel }
        , Cmd.map EditProfileMsg editProfileCmd
        )


update : Context -> Msg -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
update context msg model =
    case msg of
        SetView view ->
            ( model, Cmd.none, Just (ChangeView view) )

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
        [ button [ onClick (SetView ShowProfileView) ] [ text "View profile " ]
        , button [ onClick (SetView EditProfileView) ] [ text "Edit profile " ]
        , button [ onClick (Logout) ] [ text "Logout " ]
        ]


activeView : Context -> Model -> Html Msg
activeView context model =
    case context.activeView of
        EditProfileView ->
            Html.map EditProfileMsg (EditProfile.view model.editProfileModel)

        ShowProfileView ->
            showProfileView context.currentUser

        UnauthorizedView ->
            errorText "Unauthorized"


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
