import React from 'react';
import { requireNativeComponent } from 'react-native';
import PropTypes from 'prop-types';

class OsaiRecordView extends React.Component {
  _onChangeReadyState = (event) => {
    if (!this.props.onChangeReadyState) {
      return;
    }
    this.props.onChangeReadyState(event.nativeEvent);
  };

  _onFinishRecord = (event) => {
    if (!this.props.onFinishRecord) {
      return;
    }
    this.props.onFinishRecord(event.nativeEvent);
  };

  _onStartRecord = (event) => {
    if (!this.props.onStartRecord) {
      return;
    }
    this.props.onStartRecord(event.nativeEvent);
  };

  _onStartPreparation = (event) => {
    if (!this.props.onStartPreparation) {
      return;
    }
    this.props.onStartPreparation(event.nativeEvent);
  };

  render() {
    return (
      <OSAITableTennisRecordView
        {...this.props}
        onChangeReadyState={this._onChangeReadyState}
        onFinishRecord={this._onFinishRecord}
        onStartRecord={this._onStartRecord}
        onStartPreparation={this._onStartPreparation}
      />
    );
  }
}

OsaiRecordView.propTypes = {
  /**
   * Seconds to countdown between preparation and actual record. Default to 10 seconds
   */
   countdownSeconds: PropTypes.number,
   /**
    * Show border for our table detection. Use only for test purposes. Default to false
    */
   showTableDetection: PropTypes.bool,
   /**
    * Use ultra wide camera if can. Default to false
    */
   useUltraWideCamera: PropTypes.bool,

   /**
   * Customize font on every elements in this view
   */
   fontName: PropTypes.string,

   /**
   * Property *readyForRecord* or one of preparation flags is changed
   */
   onChangeReadyState: PropTypes.func,
   /**
   * Record is finished. You need to close record controller
   */
   onFinishRecord: PropTypes.func,
   /**
   * You need to hide your preparation views. And you can show your custom record overlay
   */
   onStartRecord: PropTypes.func,
   /**
   * You can show some custom preparation views
   */
   onStartPreparation: PropTypes.func
};

var OSAITableTennisRecordView = requireNativeComponent('OSAITableTennisRecordView');

module.exports = OsaiRecordView;
