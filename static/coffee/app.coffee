global = @


Photo = Backbone.Model.extend
  idAttribute: '_id'

  parse: (attrs) ->
    return _.from_mongo(attrs)

  get_thumbnail: (size) ->
    _.sortBy(@get('photos')[0]['alt_sizes'], (p) -> Math.abs(p.width - size))[0]


PhotoList = Backbone.Collection.extend
  model: Photo

  parse: (response) ->
    return response.photos

  load_more: (options) ->
    @fetch _.extend {
      update: true
      remove: false,
      data:
        skip: @length
    }, options || {}


TopPhotoList = PhotoList.extend
  url: '/photos'


UserLikePhotoList = PhotoList.extend
  initialize: (options) ->
    @who = options.who
    @url = "/who/#{@who}/photos"


PhotoView = Backbone.View.extend
  template: _.template($('#template-photo').html())

  render: (options) ->
    ctxt = _.extend({_view: @, options: options}, @.model)
    @$el.html(@template(ctxt))
    return @
  

PhotoListView = Backbone.View.extend
  initialize: (options) ->
    @loading = false
    @collection.on('add', @add_photo, @)
    @collection.on('reset', @reset_photo_list, @)

    @watch_tail()

    @$el
      .on('tail_reached', => @on_tail_reached())
      .masonry
        itemSelecotr: 'li'
        columnWidth: 250
        isFitWidth: true


  add_photo: (photo, collection, options) ->
    $new_node = $('<li class="photo" />')
    photoview = new PhotoView({el: $new_node, model: photo})
    photoview.render()

    @$el.append($new_node).masonry('appended', $new_node)

  reset_photo_list: (collection, options) ->
    collection.forEach (photo) =>
      @add_photo(photo, collection)

    @$el.imagesLoaded =>
      @$el.masonry('reload')

  load_more: ->
    if @loading
      return

    @collection.load_more
      success: (collection, resp, options) =>
        @$el.imagesLoaded =>
          @$el.masonry('reload')
      complete: (xhr, status) =>
        @loading = false

  on_tail_reached: () ->
    @load_more()

  watch_tail: () ->
    settings =
      threshold: 64
      container: window

    _test = ->
      height = $(document).height()
      bottom = $(window).height() + window.scrollY
      return if bottom > height - settings.threshold then true else false

    tail_reached = _test()

    # get_visible = -> !$.belowthefold(el, settings)
    # current_visible = null
    $(window).on 'scroll', =>
      if tail_reached
        if !_test()
          tail_reached = false
      else
        if _test()
          tail_reached = true
          @$el.trigger('tail_reached')


SiteTopView = Backbone.View.extend
  template: _.template($('#template-contents-site_top').html())
  events:
    'keydown input#who-liked':  'on_keydown_who_liked'

  initialize: (options) ->
    @render()
    @$who = $('input#who-liked')

    photolist = @make_photo_list(options)
    window.view = view = new PhotoListView(
      el: @$el.find('#top-photo-list')
      collection: photolist)
    photolist.fetch()

  make_photo_list: (options) ->
    return new TopPhotoList()

  render: () ->
    ctxt = _.extend({_view: @})
    @$el.html(@template(ctxt))
    return @

  on_keydown_who_liked: (e) ->
    if e.keyCode == 13
      # enter pressed
      who = @$who.val()
      if who
        global.router.navigate("who/#{who}", {trigger: true})


WhoView = SiteTopView.extend
  initialize: (options) ->
    SiteTopView.prototype.initialize.call(this, options)
    @$who.val(options.who)

  make_photo_list: (options) ->
    return new UserLikePhotoList({who: options.who})


YTLRouter = Backbone.Router.extend
  routes:
    '': 'top'
    'who/:who': 'who'

  top: ->
    view = new SiteTopView
      el: $('#contents').html('')

  who: (who) ->
    view = new WhoView
      who: who
      el: $('#contents').html('')


#####
@router = new YTLRouter()
$ ->
  if !window.is_debug
    $('#debug').remove();
  Backbone.history.start({pushState: true})

  # $('body').on 'click', 'a[href^=#]', (e) ->
  #   e.preventDefault()
  #   window.router.navigate($(this).attr('href')[1..], {trigger: true})
