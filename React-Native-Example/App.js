/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, { Component, useState } from 'react';
import type {Node} from 'react';
import { NativeModules, NativeEventEmitter } from 'react-native'
import { WebView } from 'react-native-webview';
import CookieManager from 'react-native-cookies';
import OsaiRecordView from './OsaiRecordView';
import OsaiConstants from './OsaiConstants';

import {
  SafeAreaView,
  Button,
  View,
  StyleSheet,
  ActivityIndicator,
  FlatList,
  Text,
  Image,
  TouchableOpacity,
  TouchableWithoutFeedback,
  RefreshControl
} from 'react-native';

const osaiSdk = NativeModules.OSAITableTennisSDK;
const osaiSdkEvents = new NativeEventEmitter(osaiSdk);

const { OSAIGameTypeGame, OSAIGameTypeTraining } = OsaiConstants;
const { OSAIProcessStateNotStarted, OSAIProcessStateHandling, OSAIProcessStateDone, OSAIProcessStateCancelled } = OsaiConstants;
const { OSAIGameStateLocal, OSAIGameStateUploading, OSAIGameStateUploadingPause, OSAIGameStateError, OSAIGameStateWaitForProcessing } = OsaiConstants;

class App extends Component {
  state = {
    loading: true,
    games: [],
    refreshing: false,
    reportUrl: null,
    record: false,
    prepareForRecord: false,
    prepareStateVolume: false,
    prepareStatePhoneStable: false,
    prepareStateAirplaneMode: false,
    prepareStateTableInFrame: false
  };

  componentDidMount() {
    // Setup SDK
    // You need to provide real user login
    osaiSdk.setupWithUserLogin("demo",
    "demo",
    () => {
      console.log('succes sdk setup');
      this.setState({
        loading: false,
        games: osaiSdk.getGames()
        })
      },
    (error) => {
      console.log('failed sdk setup ${error}');
      this.setState({loading: false})
      })

    // Size of one of game is changed
    osaiSdkEvents.addListener('osai_gameTotalSizeChanged', (data) => console.log(`game total size changed ${data.id}`));
    // State of one of game is changed
    osaiSdkEvents.addListener('osai_gameStateChanged', (data) => console.log(`game state changed ${data.id}`));
    // Process state of one of game is changed
    osaiSdkEvents.addListener('osai_gameProcessStateChanged', (data) => console.log(`game process state changed ${data.id}`));
    // Upload progress of one of game is changed
    osaiSdkEvents.addListener('osai_gameUploadProgressChanged', (data) => console.log(`game upload progress changed ${data.id} ${data.uploadProgress}`));
  }

  onRefresh() {
        this.setState({ refreshing: true }, function() { this.loadGames() });
     }

  onCreateGame() {
    console.log('create game');
    var user = osaiSdk.getUser();
    if (user) {
      // Create new game and show record view
      osaiSdk.createGameWithLeftPlayerName("Player 1", "Player 2", OSAIGameTypeTraining, user.userId);
      this.setState({ record: true })
    }
  }

  loadGames = async () => {
    // Fetch remote games
    osaiSdk.reloadGamesWithCompletion(() => {
      let games = osaiSdk.getGames();
      this.setState({
        games: games,
        refreshing: false
        })
      })
  }

  actionOnRow(item) {
    console.log('Selected Item :',item);
    // If game is uploaded and processing complete – you can view OSAI report
    if (item.state == OSAIGameStateWaitForProcessing && item.processState == OSAIProcessStateDone) {
      if (item.reportUrl) {
        this.setState({reportUrl: item.reportUrl});
      }
    } else {
      // If game need to be uploaded and user can upload game – let's do this
      if (item.needUpload && osaiSdk.canUploadGame()) {
        osaiSdk.uploadGameWithId(item.id);
      }
    }
  }

  onChangeReadyState(event) {
    // Ready state of record view is changed
    this.setState({
      prepareStateVolume: event.isVolumeLoud,
      prepareStatePhoneStable: event.isPhoneStable,
      prepareStateAirplaneMode: event.isAirplaneMode,
      prepareStateTableInFrame: event.isTableInFrame
      })
  }

  onFinishRecord(event) {
    // Record is finished. Close record view and refresh local games list
    let games = osaiSdk.getGames();
    this.setState({
      games: games,
      record: false
      })
  }

  onStartRecord(event) {
    // Hide preparation view
    this.setState({
      prepareForRecord: false
      })
  }

  onStartPreparation(event) {
    // Show preparation view
    this.setState({
      prepareForRecord: true
      })
  }

  recordView = () => {
    return <View style={{flex: 1, backgroundColor: "black"}}>
    <OsaiRecordView style={{ flex: 1 }}
        countdownSeconds={2}
        showTableDetection={true}
        useUltraWideCamera={false}
        fontName="Avenir-Black"
        onChangeReadyState={(event) => this.onChangeReadyState(event)}
        onStartRecord={(event) => this.onStartRecord(event)}
        onStartPreparation={(event) => this.onStartPreparation(event)}
        onFinishRecord={(event) => this.onFinishRecord(event)}/>

        {this.state.prepareForRecord ? this.preparationView() : null }
        </View>
  }

  preparationView = () => {
    return <View pointerEvents="none" style={{ backgroundColor: "clear", position: 'absolute', top: 0, right: 0, bottom: 0, left: 0}}>
      <Text style={{ padding: 10, fontSize: 18, height: 44, color: this.state.prepareStateVolume ? "green" :"red" }}>{this.state.prepareStateVolume ? 'Volume is ok' : 'Turn on volume to max' }</Text>
      <Text style={{ padding: 10, fontSize: 18, height: 44, color: this.state.prepareStatePhoneStable ? "green" :"red" }}>{this.state.prepareStatePhoneStable ? 'Phone is stable' : 'Place phone on tripod' }</Text>
      <Text style={{ padding: 10, fontSize: 18, height: 44, color: this.state.prepareStateAirplaneMode ? "green" :"red" }}>{this.state.prepareStateAirplaneMode ? 'Airplane Mode' : 'Turn on airplane mode' }</Text>
      <Text style={{ padding: 10, fontSize: 18, height: 44, color: this.state.prepareStateTableInFrame ? "green" :"red" }}>{this.state.prepareStateTableInFrame ? 'Table in frame' : 'Place table in green frame' }</Text>
    </View>
  }

  reportWebView = (source) => {
    return <View style={{flex: 1}}>
      <WebView style={{flex: 1}} source={{ uri: source }} />
      <TouchableOpacity
        style={{ height: 80, justifyContent: 'center', alignItems: 'center'}}
        onPress={() => this.setState({reportUrl: null})}>
        <Text style={{color: "white", fontWeight: 'bold', fontSize: 16}}>Back</Text>
      </TouchableOpacity>
    </View>
  }

  mainView = () => {
    return <View style={{flex: 1, backgroundColor: "black"}}>
      <FlatList
        style={{flex: 1, backgroundColor: "black"}}
        data={this.state.games}
        renderItem={({item}) =>
          <TouchableWithoutFeedback onPress={ () => this.actionOnRow(item)}>
            <View style={{flex:1, flexDirection: "row" }}>
              <Image source={{ uri: item.thumbnail}} style={{ width: 44}}/>
              <Text style={{ padding: 10, fontSize: 18, height: 44, color: "white" }}>{item.id}</Text>
            </View>
          </TouchableWithoutFeedback>
        }
        refreshControl={
            <RefreshControl
            tintColor="white"
            colors={['white']}
            refreshing={this.state.refreshing}
            onRefresh={() => this.onRefresh()}
            />
          }
      />
      <TouchableOpacity
        style={{ height: 80, justifyContent: 'center', alignItems: 'center'}}
        onPress={() => this.onCreateGame()}>
        <Text style={{color: "white", fontWeight: 'bold', fontSize: 16}}>Create game</Text>
      </TouchableOpacity>

      {this.state.loading ? <View style={{ backgroundColor: "black", position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, justifyContent: 'center', alignItems: 'center'}}>
        <ActivityIndicator size="large" color="white" />
      </View> : null}
    </View>
  }

  render() {
    return (
      <SafeAreaView style={{flex: 1, backgroundColor: "black"}}>
      {this.state.record ? this.recordView() : this.state.reportUrl ? this.reportWebView(this.state.reportUrl) : this.mainView() }
      </SafeAreaView>
    );
  };
};

export default App;
