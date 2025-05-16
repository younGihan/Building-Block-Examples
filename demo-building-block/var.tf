#variable "map_example" {
#  type = map(string)
#  description = "Ein Beispiel für eine Map (Schlüssel-Wert-Paare)."
#}

variable "list_example" {
  type = list(number)
  description = "Ein Beispiel für eine Liste von Zahlen."
}

variable "list_of_objects_example" {
  type = list(object({
    name = string
    age  = number
    city = string
  }))
  description = "Ein Beispiel für eine Liste von Objekten mit verschiedenen Attributen."
}

variable "multi_select_example" {
  type = list(string)
  description = "Ein Beispiel für eine Multi-Select von Objekten mit verschiedenen Attributen."
}
