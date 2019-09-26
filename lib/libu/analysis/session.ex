defmodule Libu.Analysis.Session do
  @moduledoc """
  Represents a stateful workflow to analyze text as it's edited over time.

  Maintains a map of chainable jobs that allows for concurrent text processing when possible.

  Keeps a reference of Collectors that aggregate analysis results into usable read models.
  """
  alias Libu.Analysis.{
    SessionMetrics,
    Job,
  }
  alias Libu.Messaging

  defstruct id: nil,
            text: "",
            changes: 0,
            job_pipeline: %{},
            collectors: %{},
            start: nil,
            last_edited_on: nil

  def new() do
    session =
      struct(__MODULE__, [
        id: UUID.uuid4(),
        start: DateTime.utc_now(),
        collectors: default_collectors(),
      ])

    Map.put(session, :job_pipeline, default_jobs(session))
  end

  def increment_changes(%__MODULE__{changes: changes} = session) do
    %__MODULE__{session | changes: changes + 1}
  end

  def default_collectors() do
    # TODO: Like default_jobs/1 we build the collector specifications we want so our runtime layers can utilize
    []
  end

  def default_jobs(%__MODULE__{} = session) do
    job_params = [queue: Libu.Analysis.Queue, context: %{session_id: session.id}]

    %{}
    |> add_job(build_job_with_params(:total_count_of_words, &SessionMetrics.count_of_words/1, job_params)) # we might have to make names unique
    |> add_job(build_job_with_params(:dale_chall_difficulty, &SessionMetrics.dale_chall_difficulty/1, job_params))
    |> add_job(build_job_with_params(:word_counts, &SessionMetrics.word_counts/1, job_params))
    |> add_job(build_job_with_params(:basic_sentiment, &SessionMetrics.basic_sentiment/1, job_params))
    |> add_job(build_job_with_params(:average_sentiment_per_word, &SessionMetrics.average_sentiment_per_word/1, job_params)) # this one should be a dependent job
    |> Enum.map(fn {_name, job} -> Job.add_dependent_job(job,
      build_job_with_params(:notify_result_as_produced, &__MODULE__.notify_as_produced/1, job_params))
    end)
    |> Enum.map(fn %Job{name: name} = job -> {name, job} end)
    |> Enum.into(%{})
  end

  defp add_job(%{} = pipeline, %Job{} = job) do
    Map.put_new(pipeline, job.name, job)
  end

  defp build_job_with_params(name, work, params) do
    Job.new(Keyword.merge([name: name, work: work], params))
  end

  def notify_as_produced(%Job{
    name: job_name,
    result: result,
    context: %{session: %__MODULE__{} = session}}
  ) do
    Libu.Analysis.Events.AnalysisResultProduced.new(
      session_id: session.id,
      text_version: session.changes,
      produced_on: DateTime.utc_now(),
      metric_name: job_name,
      result: result
    ) |> Messaging.publish(Libu.Analysis.topic() <> ":" <> session.id)
  end

  def set_text(%__MODULE__{} = session, text)
  when is_binary(text) do
    %__MODULE__{session |
      text: text,
      last_edited_on: DateTime.utc_now(),
    }
  end

  # def activate_metric(
  #   %__MODULE__{metrics: metrics} = session,
  #     metric_name
  # ) do
  #   with %Metric{active?: activity} <- Map.get(metrics, metric_name) do
  #     case activity do
  #       nil -> session
  #       _ -> %__MODULE__{ session |
  #         metrics: %{metrics | analyzer => !activity}
  #       }
  #     end
  #   end
  # end
end
