module Components.EditProfile exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (type', value, style)
import String
import HttpBuilder exposing (Error)
import Task exposing (Task)
import Api
import Types.Context as Context exposing (Context, ContextUpdate)
import Types.User as User exposing (User)


type Msg
    = Input FormUpdate
    | Submit
    | HandleResponse User
    | HandleFailure


type FormUpdate
    = FirstName String
    | LastName String
    | Age String


type alias Model =
    { profileEdit : User
    , errorMessage : Maybe String
    }


init : Context -> ( Model, Cmd Msg )
init context =
    ( { profileEdit = context.currentUser
      , errorMessage = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ContextUpdate )
update msg model =
    case msg of
        Input formUpdate ->
            ( { model | profileEdit = updateUser model.profileEdit formUpdate }
            , Cmd.none
            , Nothing
            )

        Submit ->
            ( model
            , Task.perform (\_ -> HandleFailure) HandleResponse (submit model.profileEdit)
            , Nothing
            )

        HandleResponse user ->
            ( { model | errorMessage = Nothing }
            , Cmd.none
            , Just (Context.SetCurrentUser user)
            )

        HandleFailure ->
            ( { model | errorMessage = Just "Something went wrong" }, Cmd.none, Nothing )


submit : User -> Task (Error String) User
submit user =
    User.encode user
        |> Api.put User.decoder "/api/update"
        |> Task.map .data


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
        , p [ style [ ( "color", "red" ) ] ]
            [ text (Maybe.withDefault "" model.errorMessage) ]
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
                , type' "number"
                , onInput (\input -> Input (Age input))
                ]
                []
            ]
        , div []
            [ button [ onClick Submit ] [ text "Submit" ] ]
        ]
