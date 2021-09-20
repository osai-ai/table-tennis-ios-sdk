import { NativeModules } from 'react-native';

const { OSAITableTennisSDK } = NativeModules;
const { OSAIGameType, OSAIProcessState, OSAIGameState } = OSAITableTennisSDK.getConstants();

/**
 * Type of recording game
 * Possible types:
 * OSAIGameTypeGame – Real game with referee
 * OSAIGameTypeTraining – Training game without referee
 */
const gameType = OSAIGameType;
/**
 * State of processing
 * Possible types:
 * OSAIProcessStateNotStarted – Processing of game is not started yet
 * OSAIProcessStateHandling – Processing in progress
 * OSAIProcessStateDone – Processing done, you can check report in *reportUrl*
 * OSAIProcessStateCancelled – Processing cancelled
 */
const processState = OSAIProcessState;

/**
 * State of the game
 * Possible types:
 * OSAIGameStateLocal – Game is created or recorded. Not uploaded to osai server
 * OSAIGameStateUploading – Game is uploading to osai server
 * OSAIGameStateUploadingPause – Uploading is suspended. You can resume by calling *uploadVideos* method
 * OSAIGameStateError – Uploading finished with error
 * OSAIGameStateWaitForProcessing – Game are uploaded and wait for processing
 */
const gameState = OSAIGameState;

const { OSAIGameTypeGame, OSAIGameTypeTraining } = gameType;
const { OSAIProcessStateNotStarted, OSAIProcessStateHandling, OSAIProcessStateDone, OSAIProcessStateCancelled } = processState;
const { OSAIGameStateLocal, OSAIGameStateUploading, OSAIGameStateUploadingPause, OSAIGameStateError, OSAIGameStateWaitForProcessing } = gameState;

export default {
  OSAIGameTypeGame,
  OSAIGameTypeTraining,
  OSAIProcessStateNotStarted,
  OSAIProcessStateHandling,
  OSAIProcessStateDone,
  OSAIProcessStateCancelled,
  OSAIGameStateLocal,
  OSAIGameStateUploading,
  OSAIGameStateUploadingPause,
  OSAIGameStateError,
  OSAIGameStateWaitForProcessing
};
