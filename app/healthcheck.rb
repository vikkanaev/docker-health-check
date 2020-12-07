class Healthcheck
  class << self
    # по нечетным десятиминуткам возвращает ошибку. По четным - нормальный статус
    def call
      odd = (Time.now.min / 10).odd?
      if odd
        puts("Error! Your app is NOT OK!")
        exit 1
      else
        puts("App is OK!")
        exit 0
      end
    end
  end
end

Healthcheck.call
