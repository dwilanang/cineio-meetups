# @cjsx React.DOM
React = require('react')
assign = require("object-assign")
JoinRoom = require('./JoinRoom.react')
IncomingCall = require('./IncomingCall.react')
OngoingCall = require('./OngoingCall.react')
Call = require('./Call.react')
Identify = require('./Identify.react')
SessionStore = require('../stores/SessionStore')
PeerStore = require('../stores/PeerStore')
SessionActionCreators = require('../actions/SessionActionCreators')

stateFromSessionStore = ->
  return {incomingCall: PeerStore.getIncomingCall(), currentRoom: SessionStore.getCurrentRoom(), muted: SessionStore.muted(), identity: SessionStore.getIdentity()}

module.exports = React.createClass

  getInitialState: ->
    return assign({identifying: false, calling: false, joiningRoom: false, callingSomebody: false}, stateFromSessionStore())

  joinRoom: (event)->
    event.preventDefault()
    @setState(joiningRoom: true)

  identify: (event)->
    event.preventDefault()
    @setState(identifying: true)

  call: (event)->
    event.preventDefault()
    @setState(calling: true)

  exitJoinRoom: ->
    @setState(joiningRoom: false)

  exitCall: ->
    @setState(calling: false)

  exitIdentify: ->
    @setState(identifying: false)

  mute: (event)->
    event.preventDefault()
    SessionActionCreators.mute()

  unmute: (event)->
    event.preventDefault()
    SessionActionCreators.unmute()

  componentDidMount: ->
    SessionStore.addChangeListener(this._onChange)
    PeerStore.addChangeListener(this._onChange)

  componentWillUnmount: ->
    SessionStore.removeChangeListener(this._onChange)
    PeerStore.removeChangeListener(this._onChange)

  _onChange: ->
    @setState(stateFromSessionStore())

  leaveRoom: (event)->
    SessionActionCreators.leaveRoom(@state.currentRoom)
    event.preventDefault()

  render: ->
    if @state.incomingCall
      if @state.incomingCall.ongoing
        view = (<OngoingCall call={@state.incomingCall} />)
      else
        view = (<IncomingCall call={@state.incomingCall} />)
    else if @state.joiningRoom
      view = (<JoinRoom callback={@exitJoinRoom} />)
    else if @state.identifying
      view = (<Identify callback={@exitIdentify} />)
    else if @state.calling
      view = (<Call callback={@exitCall} />)
    else
      if @state.muted
        muteButton = (<button onClick={@unmute}>Unmute</button>)
      else
        muteButton = (<button onClick={@mute}>Mute</button>)

      if @state.currentRoom
        roomButton = (<button onClick={@leaveRoom}>Leave {@state.currentRoom}</button>)
      else
        roomButton = (<button onClick={@joinRoom}>Join Room</button>)

      if @state.identity
        callButton = (<button onClick={@call}>({@state.identity}) Call</button>)
      else
        callButton = (<button onClick={@identify}>Identify</button>)
      view = (
        <ul>
          <li>
            {muteButton}
          </li>
          <li>
            {callButton}
          </li>
          <li>
            {roomButton}
          </li>
        </ul>
      )
    return (
      <div className="controls">
        {view}
      </div>
    )

