class Node
  JSON.mapping(
    ip: String,
    ip6: String,
    city: String,
    country: String,
    lat: Float64,
    lng: Float64,
  )
end
