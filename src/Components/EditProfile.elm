module Components.EditProfile exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (type_, value, style)
import String
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (put)
import Types exposing (Context, ContextUpdate(..), User)
import Encoders exposing (encodeUser)
import Decoders exposing (userDecoder)
import Helpers exposing (errorMessageView)


type Msg
    = Input FormUpdate
    | Submit
    | HandleResponse (WebData User)


type FormUpdate
    = FirstName String
    | LastName String
    | Age String


type alias Model =
    { profileEdit : User
    , userResponse : WebData User
    }


init : Context -> ( Model, Cmd Msg )
init context =
    ( { profileEdit = context.currentUser
      , userResponse = NotAsked
      }
    , Cmd.none
    )


update : Context -> Msg -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
update context msg model =
    case msg of
        Input formUpdate ->
            ( { model | profileEdit = updateUser model.profileEdit formUpdate }
            , Cmd.none
            , Nothing
            )

        Submit ->
            ( model
            , submit model.profileEdit
            , Nothing
            )

        HandleResponse webData ->
            case webData of
                Success user ->
                    ( { model
                        | userResponse = webData
                        , profileEdit = user
                      }
                    , Cmd.none
                    , Just (SetCurrentUser user)
                    )

                _ ->
                    ( { model | userResponse = webData }
                    , Cmd.none
                    , Nothing
                    )


submit : User -> Cmd Msg
submit user =
    put "/api/update" HandleResponse userDecoder (encodeUser user)


updateUser : User -> FormUpdate -> User
updateUser user formUpdate =
    case formUpdate of
        FirstName value ->
            { user | firstName = value }

        LastName value ->
            { user | lastName = value }

        Age value ->
            { user | age = Result.withDefault 0 (String.toInt value) }


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Edit Profile" ]
        , errorMessageView model.userResponse
        , formView model.profileEdit
        ]


formView : User -> Html Msg
formView user =
    div []
        [ div []
            [ span [] [ text "First name" ]
            , input
                [ value user.firstName
                , onInput (\input -> Input (FirstName input))
                ]
                []
            ]
        , div []
            [ span [] [ text "Last name" ]
            , input
                [ value user.lastName
                , onInput (\input -> Input (LastName input))
                ]
                []
            ]
        , div []
            [ span [] [ text "Age" ]
            , input
                [ value (toString user.age)
                , type_ "number"
                , onInput (\input -> Input (Age input))
                ]
                []
            ]
        , div []
            [ button [ onClick Submit ] [ text "Submit" ] ]
        ]
