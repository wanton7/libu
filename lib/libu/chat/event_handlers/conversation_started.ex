defmodule Libu.Chat.EventHandlers.ConversationStarted do
  @moduledoc """
  Handles events from Commanded internals and republishes them to our Messaging context.

  Here we start from `:origin` in this global event handler to then spawn a conversation-specific event-handler to maintain a projection.

  We spawn the event_handlers under a dynamic supervisor.

  TODO: Create an active_conversation_projection event_handler with a custom init for ets
  TODO: Create a ConversationProjectionManager that spawns an event_handler for each conversation
    - Spawn under a DynamicSupervisor with start_child
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    consistency: :eventual,
    start_from: :current

  alias Libu.Chat.Events.ConversationStarted
  alias Libu.Messaging
  alias Libu.Chat
  alias Libu.Chat.Projections

  def handle(%ConversationStarted{conversation_id: convo_id} = event, _metadata) do
    Messaging.publish(event, Chat.topic() <> ":" <> convo_id)
    :ok
  end
end
