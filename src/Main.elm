port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Time exposing (Time, second, minute)

---- MODEL ----


type alias Model =
    { app: AppTypes, state: ClockStates, minutes:Int, seconds:Int }

initModel : Model
initModel =
    { app = Pomodoro, state = Paused, minutes = 25, seconds = 0 }


init : ( Model, Cmd Msg )
init =
    ( initModel , Cmd.none )


---- UPDATE ----

type ClockStates = Paused | Running | Complete
type AppTypes = Pomodoro | Break | LongBreak

type Msg
    = NoOp
    | Tick Time
    | UpdateClockState ClockStates
    | UpdateAppType AppTypes


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAppType Break ->
            ( { model | state = Running, minutes = 5, seconds = 0, app = Break } , Cmd.none )
        UpdateAppType Pomodoro ->
            ( { model | state = Running, minutes = 25, seconds = 0, app = Pomodoro } , Cmd.none )
        Tick time ->
            if model.state == Running then
                let
                    newSeconds = if (model.seconds == 0) then 59 else model.seconds - 1
                    newMinutes = if (newSeconds == 59) then model.minutes - 1 else model.minutes
                in
                    if newMinutes >= 0 && newSeconds >= 0 then
                            ( { model | seconds = newSeconds, minutes = newMinutes } , Cmd.none )
                    else
                        let
                            action = if model.app == Pomodoro then "break" else "work"
                        in
                        ( { model | state = Complete } , sendNotification ("it's time for " ++ action))
            else
                ( model, Cmd.none )
        UpdateClockState state ->
            ( { model | state = state} , Cmd.none )
        _ ->
            ( model, Cmd.none )



---- VIEW ----
padWithZero : Int -> String
padWithZero n =
    if (n < 10) then
        "0" ++ (toString n)
    else
        (toString n)

renderButton : ClockStates -> AppTypes -> Html Msg
renderButton state appType =
    case state of
        Running ->
            button [onClick (UpdateClockState Paused)] [ text "Pause"]
        Paused ->
            button [onClick (UpdateClockState Running)] [ text "Start"]
        Complete ->
            let
                nextAppType = if appType == Pomodoro then Break else Pomodoro
            in
                button [onClick (UpdateAppType nextAppType)] [ text "Start"]


view : Model -> Html Msg
view model =
    div []
        [ img [ src "https://revathskumar.github.io/pomodoro/logo.svg" ] []
        , h1 [] [ text (if model.app == Pomodoro then "Work" else "Break") ]
        , div [class "time"] [
            text ((padWithZero model.minutes) ++ ":" ++ (padWithZero model.seconds))
            ]
        , renderButton model.state model.app
        ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    if model.state == Running  then
        Time.every second Tick
    else
        Sub.none
        -- Time.every minute Tick

port sendNotification : String -> Cmd msg


---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
