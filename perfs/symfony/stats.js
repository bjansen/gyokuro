var stats = {
    type: "GROUP",
name: "Global Information",
path: "",
pathFormatted: "group_missing-name-b06d1",
stats: {
    "name": "Global Information",
    "numberOfRequests": {
        "total": "1000",
        "ok": "1000",
        "ko": "0"
    },
    "minResponseTime": {
        "total": "53",
        "ok": "53",
        "ko": "-"
    },
    "maxResponseTime": {
        "total": "5997",
        "ok": "5997",
        "ko": "-"
    },
    "meanResponseTime": {
        "total": "485",
        "ok": "485",
        "ko": "-"
    },
    "standardDeviation": {
        "total": "1056",
        "ok": "1056",
        "ko": "-"
    },
    "percentiles1": {
        "total": "183",
        "ok": "183",
        "ko": "-"
    },
    "percentiles2": {
        "total": "301",
        "ok": "302",
        "ko": "-"
    },
    "percentiles3": {
        "total": "3084",
        "ok": "3084",
        "ko": "-"
    },
    "percentiles4": {
        "total": "4932",
        "ok": "4932",
        "ko": "-"
    },
    "group1": {
        "name": "t < 800 ms",
        "count": 911,
        "percentage": 91
    },
    "group2": {
        "name": "800 ms < t < 1200 ms",
        "count": 10,
        "percentage": 1
    },
    "group3": {
        "name": "t > 1200 ms",
        "count": 79,
        "percentage": 8
    },
    "group4": {
        "name": "failed",
        "count": 0,
        "percentage": 0
    },
    "meanNumberOfRequestsPerSecond": {
        "total": "127.226",
        "ok": "127.226",
        "ko": "-"
    }
},
contents: {
"req_hello-8b1a9": {
        type: "REQUEST",
        name: "Hello",
path: "Hello",
pathFormatted: "req_hello-8b1a9",
stats: {
    "name": "Hello",
    "numberOfRequests": {
        "total": "1000",
        "ok": "1000",
        "ko": "0"
    },
    "minResponseTime": {
        "total": "53",
        "ok": "53",
        "ko": "-"
    },
    "maxResponseTime": {
        "total": "5997",
        "ok": "5997",
        "ko": "-"
    },
    "meanResponseTime": {
        "total": "485",
        "ok": "485",
        "ko": "-"
    },
    "standardDeviation": {
        "total": "1056",
        "ok": "1056",
        "ko": "-"
    },
    "percentiles1": {
        "total": "183",
        "ok": "183",
        "ko": "-"
    },
    "percentiles2": {
        "total": "302",
        "ok": "302",
        "ko": "-"
    },
    "percentiles3": {
        "total": "3084",
        "ok": "3084",
        "ko": "-"
    },
    "percentiles4": {
        "total": "4932",
        "ok": "4932",
        "ko": "-"
    },
    "group1": {
        "name": "t < 800 ms",
        "count": 911,
        "percentage": 91
    },
    "group2": {
        "name": "800 ms < t < 1200 ms",
        "count": 10,
        "percentage": 1
    },
    "group3": {
        "name": "t > 1200 ms",
        "count": 79,
        "percentage": 8
    },
    "group4": {
        "name": "failed",
        "count": 0,
        "percentage": 0
    },
    "meanNumberOfRequestsPerSecond": {
        "total": "127.226",
        "ok": "127.226",
        "ko": "-"
    }
}
    }
}

}

function fillStats(stat){
    $("#numberOfRequests").append(stat.numberOfRequests.total);
    $("#numberOfRequestsOK").append(stat.numberOfRequests.ok);
    $("#numberOfRequestsKO").append(stat.numberOfRequests.ko);

    $("#minResponseTime").append(stat.minResponseTime.total);
    $("#minResponseTimeOK").append(stat.minResponseTime.ok);
    $("#minResponseTimeKO").append(stat.minResponseTime.ko);

    $("#maxResponseTime").append(stat.maxResponseTime.total);
    $("#maxResponseTimeOK").append(stat.maxResponseTime.ok);
    $("#maxResponseTimeKO").append(stat.maxResponseTime.ko);

    $("#meanResponseTime").append(stat.meanResponseTime.total);
    $("#meanResponseTimeOK").append(stat.meanResponseTime.ok);
    $("#meanResponseTimeKO").append(stat.meanResponseTime.ko);

    $("#standardDeviation").append(stat.standardDeviation.total);
    $("#standardDeviationOK").append(stat.standardDeviation.ok);
    $("#standardDeviationKO").append(stat.standardDeviation.ko);

    $("#percentiles1").append(stat.percentiles1.total);
    $("#percentiles1OK").append(stat.percentiles1.ok);
    $("#percentiles1KO").append(stat.percentiles1.ko);

    $("#percentiles2").append(stat.percentiles2.total);
    $("#percentiles2OK").append(stat.percentiles2.ok);
    $("#percentiles2KO").append(stat.percentiles2.ko);

    $("#percentiles3").append(stat.percentiles3.total);
    $("#percentiles3OK").append(stat.percentiles3.ok);
    $("#percentiles3KO").append(stat.percentiles3.ko);

    $("#percentiles4").append(stat.percentiles4.total);
    $("#percentiles4OK").append(stat.percentiles4.ok);
    $("#percentiles4KO").append(stat.percentiles4.ko);

    $("#meanNumberOfRequestsPerSecond").append(stat.meanNumberOfRequestsPerSecond.total);
    $("#meanNumberOfRequestsPerSecondOK").append(stat.meanNumberOfRequestsPerSecond.ok);
    $("#meanNumberOfRequestsPerSecondKO").append(stat.meanNumberOfRequestsPerSecond.ko);
}
