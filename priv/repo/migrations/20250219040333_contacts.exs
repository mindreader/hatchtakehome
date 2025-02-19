defmodule Hatch.Repo.Migrations.Contacts do
  use Ecto.Migration

  # TODO would typically add inserted_at updated_at timestamps

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :email_address, :string
      add :phone_number, :string
    end

    create unique_index(:conversations, [:email_address])
    create unique_index(:conversations, [:phone_number])

    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :type, :string, null: false
      add :received_at, :utc_datetime
      add :sent_at, :utc_datetime

      add :conversation_id, references(:conversations, type: :binary_id)
    end

    create table(:emails, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :unique_id, :string
      add :from, :string, null: false
      add :to, :string, null: false
      add :body, :string, null: false
      add :date, :utc_datetime, null: false

      add :message_id, references(:messages, type: :binary_id)
    end

    create table(:texts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :unique_id, :string
      add :from, :string, null: false
      add :to, :string, null: false
      add :body, :string, null: false
      add :date, :utc_datetime, null: false
      add :type, :string, null: false

      add :message_id, references(:messages, type: :binary_id)
    end

    create table(:attachments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :url, :string, null: false
      add :message_id, references(:messages, type: :binary_id)
    end
  end
end
