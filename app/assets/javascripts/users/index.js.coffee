$ ->
  loading = false
  page    = 1

  load_page = (page) ->
    loading = true

    $.get('/rankings', { page: page })
      .success((data, status, xhr) =>
        $('#ladder tbody').append(data)
        loading = false
      )

  if $('#users-index').length
    $(window).scroll( =>
      if $(window).scrollTop() + $(window).height() > $(document).height() - 100
        if loading == false && !$('.friends.selected').length
          page = page + 1
          load_page(page)
    )
