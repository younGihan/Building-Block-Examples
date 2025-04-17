variable "map_example" {
  type = map(string)
  default = {
    "key1" = "value1"
    "key2" = "value2"
    "key3" = "value3"
  }
  description = "Ein Beispiel für eine Map (Schlüssel-Wert-Paare)."
}

variable "list_example" {
  type = list(number)
  default = [10, 20, 30, 40, 50]
  description = "Ein Beispiel für eine Liste von Zahlen."
}

variable "list_of_objects_example" {
  type = list(object({
    name = string
    age  = number
    city = string
  }))
  default = [
    {
      name = "Alice"
      age  = 30
      city = "Berlin"
    },
    {
      name = "Bob"
      age  = 25
      city = "Hamburg"
    },
    {
      name = "Charlie"
      age  = 35
      city = "München"
    }
  ]
  description = "Ein Beispiel für eine Liste von Objekten mit verschiedenen Attributen."
}