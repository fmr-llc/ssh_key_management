AjaxDatatablesRails.configure do |config|
  # available options for db_adapter are: :pg, :mysql2, :sqlite3
  config.db_adapter = :mysql2
  config.paginator = :kaminari
end
