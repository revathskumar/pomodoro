module Tests exposing (..)

import Test exposing (..)
import Expect
import Time exposing (Time)
import Test.Html.Query as Query
import Test.Html.Selector exposing (text, tag, attribute, class)

import Main exposing (initModel)

updateAppTypeSelectAppType : Test
updateAppTypeSelectAppType =
    describe "UpdateAppType select the app type and set starting time"
        [ test "break should set minutes to 5" <|
            \_ ->
                Main.initModel
                    |> Main.update (Main.UpdateAppType Main.Break)
                    |> Tuple.first
                    |> .minutes
                    |> Expect.equal 5
        , test "pomodoro should set minutes to 25" <|
            \_ ->
                Main.initModel
                    |> Main.update (Main.UpdateAppType Main.Break)
                    |> Tuple.first
                    |> Main.update (Main.UpdateAppType Main.Pomodoro)
                    |> Tuple.first
                    |> .minutes
                    |> Expect.equal 25
        ]

updateClockStateSelectClockState : Test
updateClockStateSelectClockState =
    describe "UpdateClockState should select the clockState"
        [ test "should set as Running" <|
            \_ ->
                Main.initModel
                    |> Main.update (Main.UpdateClockState Main.Running)
                    |> Tuple.first
                    |> .state
                    |> Expect.equal Main.Running
        ]

updateTick : Test
updateTick =
    describe "on Running clockState"
        [ test "should update the seconds" <|
            \_ ->
                { initModel | state = Main.Running }
                    |> Main.update (Main.Tick Time.second)
                    |> Tuple.first
                    |> .seconds
                    |> Expect.equal 59
        , test "on zero, should set state to Complete" <|
            \_ ->
                { initModel | state = Main.Running, seconds = 0, minutes = 0 }
                    |> Main.update (Main.Tick Time.second)
                    |> Tuple.first
                    |> .state
                    |> Expect.equal Main.Complete
        , test "on zero, should send the sendNotification command" <|
            \_ ->
                { initModel | state = Main.Running, seconds = 0, minutes = 0 }
                    |> Main.update (Main.Tick Time.second)
                    |> Tuple.second
                    |> Expect.equal (Main.sendNotification "it's time for break")
        ]

initialView : Test
initialView =
    describe "on initial view"
        [  test "should render work as heading" <|
            \_ ->
                initModel
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.find [tag "h1"]
                    |> Query.has [ text "Work" ]
        ,  test "should render Start button" <|
            \_ ->
                initModel
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.find [tag "button"]
                    |> Query.has [ text "Start" ]
        ,  test "should render time padded with zero" <|
            \_ ->
                initModel
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.find [class "time"]
                    |> Query.has [ text "25:00" ]
        ]

renderBreakView :Test
renderBreakView =
    describe "on break view"
        [  test "should render break as heading" <|
            \_ ->
                { initModel | app = Main.Break }
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.find [tag "h1"]
                    |> Query.has [ text "Break" ]
        ,  test "should render time padded with zero" <|
            \_ ->
                initModel
                    |> Main.update (Main.UpdateAppType Main.Break)
                    |> Tuple.first
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.find [class "time"]
                    |> Query.has [ text "05:00" ]
        ]

renderRunningView : Test
renderRunningView =
    describe "on running state"
        [  test "should render pause button" <|
            \_ ->
                { initModel | state = Main.Running }
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.find [tag "button"]
                    |> Query.has [ text "Pause" ]
        ]
