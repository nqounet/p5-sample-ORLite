var main = new Vue({
    el: '#main',
    data: {
        title: 'ORLite',
        now: moment().format('YYYY-MM-DD HH:mm:ss'),
        entries: [],
    },
    methods: {
        submit: function() {
            console.debug('arguments:', arguments);
            var $data = this.$data;
            oboe({
                url: '/api/v1/entries',
                method: 'post',
                body: {
                    msg: $data.msg
                }
            }).done(function() {
                $data.msg = '';
            });
        }
    }
});
